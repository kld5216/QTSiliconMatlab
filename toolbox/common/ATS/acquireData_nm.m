function [data] = acquireData_nm(boardHandle,postTriggerSamples,recordsPerBuffer)
% Make an AutoDMA acquisition from dual-ported memory.

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2015 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

% global variable set in configureBoard.m
global samplesPerSec;

% set default return code to indicate failure
% result = false;

% call mfile with library definitions
AlazarDefs
% There are no pre-trigger samples in NPT mode
preTriggerSamples = 0;%触发前采集数据点数
% TODO: Select the number of post-trigger samples per record
% postTriggerSamples = 1024;%，触发后采集的点数，若preTriggerSamples为0，则代表单次record采集的数据




% TODO: Specify the number of records per channel per DMA buffer
% recordsPerBuffer = 10;%buffersPerAcquisition为1时，代表单次采集的records数
% recordsPerBuffer = recordsPerBuffer;

% TODO: Specifiy the total number of buffers to capture
buffersPerAcquisition = 1;
% buffersPerAcquisition = 10;

% TODO: Select which channels to capture (A, B, or both)
channelMask = CHANNEL_A;% + CHANNEL_B;
channelsPerBoard = 1;%%设置使用channel数

% TODO: Select AutoDMA flags as required
admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_NPT;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;
% TODO: Select if you wish to plot the data to a chart
drawData = true;


% Calculate the number of enabled channels from the channel mask 
channelCount = 0;
for channel = 0:channelsPerBoard - 1
    channelId = 2^channel;
    if bitand(channelId, channelMask)
        channelCount = channelCount + 1;
    end
end

if (channelCount < 1) || (channelCount > channelsPerBoard)
    fprintf('Error: Invalid channel mask %08X\n', channelMask);
    return
end

% Get the sample and memory size
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = AlazarGetChannelInfo(boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

% Calculate the size of each buffer in bytes
bytesPerSample = floor((double(bitsPerSample) + 7) / double(8));%%？
samplesPerRecord = preTriggerSamples + postTriggerSamples;
if samplesPerRecord > maxSamplesPerRecord
    fprintf('Error: Too many samples per record %u max %u\n', samplesPerRecord, maxSamplesPerRecord);
    return
end
samplesPerBuffer = samplesPerRecord * recordsPerBuffer * channelCount;
bytesPerBuffer = bytesPerSample * samplesPerBuffer;

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
bufferCount = uint32(4);

% Create an array of DMA buffers
buffers = cell(1, bufferCount);
for j = 1 : bufferCount
    pbuffer = AlazarAllocBuffer(boardHandle, bytesPerBuffer);
    if pbuffer == 0
        fprintf('Error: AlazarAllocBuffer %u samples failed\n', samplesPerBuffer);
        return
    end
    buffers(1, j) = { pbuffer };
end

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    if fid == -1
        fprintf('Error: Unable to create data file\n');
    end
end
% Set the record size
retCode = AlazarSetRecordSize(boardHandle, preTriggerSamples, postTriggerSamples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetRecordSize failed -- %s\n', errorToText(retCode));
    return
end



% Configure the board to make an AutoDMA acquisition
recordsPerAcquisition = recordsPerBuffer * buffersPerAcquisition;
retCode = AlazarBeforeAsyncRead(boardHandle, channelMask, -int32(preTriggerSamples), samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, admaFlags);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
    return
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
        return
    end
end

% Update status
% if buffersPerAcquisition == hex2dec('7FFFFFFF')
%     fprintf('Capturing buffers until aborted...\n');
% else
%     fprintf('Capturing %u buffers ...\n', buffersPerAcquisition);
% end

% Arm the board system to wait for triggers
retCode = AlazarStartCapture(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return
end

% Create a progress window
% waitbarHandle = waitbar(0, ...
%                         'Captured 0 buffers', ...
%                         'Name','Capturing ...', ...
%                         'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
% setappdata(waitbarHandle, 'canceling', 0);

% Wait for sufficient data to arrive to fill a buffer, process the buffer,
% and repeat until the acquisition is complete
startTickCount = tic;
updateTickCount = tic;
updateInterval_sec = 0.1;
buffersCompleted = 0;
captureDone = false;
success = false;

while ~captureDone

    bufferIndex = mod(buffersCompleted, bufferCount) + 1;
    pbuffer = buffers{1, bufferIndex};

    % Wait for the first available buffer to be filled by the board
    [retCode, boardHandle, bufferOut] = ...
        AlazarWaitAsyncBufferComplete(boardHandle, pbuffer, 5000);
    if retCode == ApiSuccess
        % This buffer is full
        bufferFull = true;
        captureDone = false;
    elseif retCode == ApiWaitTimeout
        % The wait timeout expired before this buffer was filled.
        % The board may not be triggering, or the timeout period may be too short.
        fprintf('Error: AlazarWaitAsyncBufferComplete timeout -- Verify trigger!\n');
        bufferFull = false;
        captureDone = true;
    else
        % The acquisition failed
        fprintf('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', errorToText(retCode));
        bufferFull = false;
        captureDone = true;
    end

    if bufferFull
        % TODO: Process sample data in this buffer.
        %
        % NOTE:
        %
        % While you are processing this buffer, the board is already
        % filling the next available buffer(s).
        %
        % You MUST finish processing this buffer and post it back to the
        % board before the board fills all of its available DMA buffers
        % and on-board memory.
        %
        % Records are arranged in the buffer as follows: R0A, R1A, R2A ... RnA, R0B,
        % R1B, R2B ...
        % with RXY the record number X of channel Y
        %
        % A 12-bit sample code is stored in the most significant bits of
        % in each 16-bit sample value.
        %
        % Sample codes are unsigned by default. As a result:
        % - a sample code of 0x0000 represents a negative full scale input signal.
        % - a sample code of 0x8000 represents a ~0V signal.
        % - a sample code of 0xFFFF represents a positive full scale input signal.

        if bytesPerSample == 1
            setdatatype(bufferOut, 'uint8Ptr', 1, samplesPerBuffer);
        else
            setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
        end

        % Save the buffer to file
        if fid ~= -1
            if bytesPerSample == 1
                samplesWritten = fwrite(fid, bufferOut.Value, 'uint8');
            else
                samplesWritten = fwrite(fid, bufferOut.Value, 'uint16');%写入的数据为16位
            end
            if samplesWritten ~= samplesPerBuffer
                fprintf('Error: Write buffer %u failed\n', buffersCompleted);
            end
        end

        % Display the buffer on screen
        if drawData
%             plot(bufferOut.Value);
%             subplot(2,1,1);
%             plot(bufferOut.Value(1:2:samplesPerBuffer));
%             subplot(2,1,2);
%             plot(bufferOut.Value(2:2:samplesPerBuffer));
%             addpath('.\ATS')
%             for i=1:recordsPerBuffer
%                 data.CHA(i) = SampleToVoltsU12(bufferOut.Value(1+(i-1)*samplesPerRecord:2:i*samplesPerRecord),0.4);
%                 data.CHB(i) = SampleToVoltsU12(bufferOut.Value(2+(i-1)*samplesPerRecord:2:i*samplesPerRecord),0.4);
%             end
            
        end
        
        data = bufferOut.Value;
        
        % Make the buffer available to be filled again by the board
        retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
            captureDone = true;
        end

        % Update progress
        buffersCompleted = buffersCompleted + 1;
        if buffersCompleted >= buffersPerAcquisition
            captureDone = true;
            success = true;
        elseif toc(updateTickCount) > updateInterval_sec
            updateTickCount = tic;

            % Update waitbar progress
%             waitbar(double(buffersCompleted) / double(buffersPerAcquisition), ...
%                     waitbarHandle, ...
%                     sprintf('Completed %u buffers', buffersCompleted));

            % Check if waitbar cancel button was pressed
%             if getappdata(waitbarHandle,'canceling')
%                 break
%             end
        end

    end % if bufferFull

end % while ~captureDone

% Save the transfer time
transferTime_sec = toc(startTickCount);

% Close progress window
% delete(waitbarHandle);

% Abort the acquisition
retCode = AlazarAbortAsyncRead(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
end

% Close the data file
if fid ~= -1
    fclose(fid);
end

% Release the buffers
for bufferIndex = 1:bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarFreeBuffer(boardHandle, pbuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarFreeBuffer failed -- %s\n', errorToText(retCode));
    end
    clear pbuffer;
end

% Display results
% if buffersCompleted > 0
%     bytesTransferred = double(buffersCompleted) * double(bytesPerBuffer);
%     recordsTransferred = recordsPerBuffer * buffersCompleted;
% 
%     if transferTime_sec > 0
%         buffersPerSec = buffersCompleted / transferTime_sec;
%         bytesPerSec = bytesTransferred / transferTime_sec;
%         recordsPerSec = recordsTransferred / transferTime_sec;
%     else
%         buffersPerSec = 0;
%         bytesPerSec = 0;
%         recordsPerSec = 0.;
%     end
% 
%     fprintf('Captured %u buffers in %g sec (%g buffers per sec)\n', buffersCompleted, transferTime_sec, buffersPerSec);
%     fprintf('Captured %u records (%.4g records per sec)\n', recordsTransferred, recordsPerSec);
%     fprintf('Transferred %u bytes (%.4g bytes per sec)\n', bytesTransferred, bytesPerSec);
% end

% set return code to indicate success
% result = success;
end