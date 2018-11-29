classdef CATS_nm < handle
    %CATS �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        boardHandle;
        sampleRate ;
        sampleCount ;
        repeatCount ;
    end
    
    methods
        function obj = CATS_nm(systemId)%�������غ����⣻ָ��ʹ�ð忨��ID������ָ��ɼ����ľ��boardHandle
            boardId = 1;
            addpath([getCommonDir(),'ATSInclude']);
            % Call mfile with library definitions
            AlazarDefs;%��ʼ������
            % Load driver library
            if ~alazarLoadLibrary()
                fprintf('Error: ATSApi library not loaded\n');
                return
            end
            % TODO: Select a board
            systemId = int32(systemId);
            boardId = int32(boardId);
            % Get a handle to the board
            obj.boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
            setdatatype(obj.boardHandle, 'voidPtr', 1, 1);%Set Size and Type
            if obj.boardHandle.Value == 0
                fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
                return
            end
        end
        
        
        
        %%���ú��� Ԥ��
        function config(obj)
            
%             value = uint32(0);
%             p = libpointer('uint32Ptr',value);
%             AlazarDefs;
%            [retCode, boardHandle, pValue] = AlazarGetParameter(obj.boardHandle,CHANNEL_ALL,DATA_WIDTH,p);
%            disp('www');
        end
        
        function setPara(obj,sampleRate,sampleCount,repeatCount)%���ò���
            obj.sampleRate = sampleRate;
            obj.sampleCount = sampleCount;
            obj.repeatCount = repeatCount;
        end
        
        function setSampleRate(obj,sampleRate)
            obj.sampleRate = sampleRate;
        end
        function setSampleCount(obj,sampleCount)
            obj.sampleCount = sampleCount;
        end
        function setRepeatCount(obj,repeatCount)
            obj.repeatCount = repeatCount;
        end
        
        %%�ɼ�����
        function data = acquire(obj,voltage)
            import instrument.ATS.*;
            dataOrigin = acquireData_nm(obj.boardHandle,obj.sampleCount,obj.repeatCount);%���ݰ忨����Ͳ������ɼ����ݲ����ظ�dataOrigin
            
            data.CHA = zeros(obj.repeatCount,obj.sampleCount);
          %  data.CHB = zeros(obj.repeatCount,obj.sampleCount);

          
          
          
            for m=1:obj.repeatCount
               data.CHA(m,:) = obj.SampleToVoltsU14(dataOrigin(1 + (m-1)*obj.sampleCount*2 : 1 : (m-0.5)*obj.sampleCount*2),voltage);%���������ѹ��ֵ
             % data.CHB(m,:) = obj.SampleToVoltsU14(dataOrigin( 1 + (m-0.5)*obj.sampleCount*2 : 1  :m*obj.sampleCount*2) ,0.4);
            end
            
%             data.CHA = cell(1,obj.repeatCount);
%             data.CHB = cell(1,obj.repeatCount);
%             for m=1:obj.repeatCount
%                 data.CHA{m} = obj.SampleToVoltsU12(dataOrigin( 1 + (m-1)*obj.sampleCount*2 : 2 : m*obj.sampleCount*2 ),0.4);
%                 data.CHB{m} = obj.SampleToVoltsU12(dataOrigin( 2 + (m-1)*obj.sampleCount*2 : 2  :m*obj.sampleCount*2 ),0.4);
%             end

        end
        
        %%����ת��
        function [ sampleVoltsList ] = SampleToVoltsU14(~,sampleValueList , inputRange_volts )
           sampleValueList = bitshift(sampleValueList,-2);
            sampleValueList_ = double(sampleValueList);
           sampleVoltsList = (sampleValueList_-8192)/8192 * inputRange_volts;
        end
    end
    
end