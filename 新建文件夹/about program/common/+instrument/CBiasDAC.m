classdef CBiasDAC < handle
    %电压源共有12个电压输出 使用1~6为U1~U6 7~12 为D1~D6
    %% 
     properties
        fs;
        BaudRate=115200;
     end
    
    methods
        %初始化
        function obj = CBiasDAC(server_ip)
                obj.fs=serial(server_ip);
                obj.fs.BaudRate=obj.BaudRate;
                fopen(obj.fs);
%                 init_DAC(obj.fs);  %需要初始化！！！！
        end      
        
 %% 仪器自检
        function rtn_check(obj,cmd, rtn)
        % BiasDAC reading check, check sending and last 0xBF
        % KillerFrank, 2011-11-04 13:01

            if ~(cmd == rtn(1))
                error_breaker('BiasDAC input not consist!');
            end

            % if ~(rtn(end) == 191)                 % v1 v2
            if ~(rtn(end) == 10)                  % v3
                error_breaker('BiasDAC reading error!');
            end
        end   
        
 %% 数值转换
        function d_value = str2value(obj,str)
        % BiasDAC reading convert to float data
        % KillerFrank, 2011-11-04 12:57

            d_value = (str(2)*16384 + str(3)*128 + str(4))*(-10)/8/262143; % New BiasDAC, 18bit
            % d_value = (str(2)*16384 + str(3)*128 + str(4))*(-10)/2/1048575; % Old BiasDAC, 20bit
            d_value = round(d_value*1e4)/1e4;
        end
       
        %——————————————————————————
        
         function d_str = value2str(obj,idx, value)
        % BiasDAC writing convert to string
        % KillerFrank, 2011-11-04 21:50

            d_str(1) = idx-1+16;
            tmp = idivide(int32(value*262143), int32(-10), 'fix');
            d_str(2) = idivide(int32(tmp), int32(2048), 'fix');
            d_str(3) = idivide(int32(mod(tmp, 2048)), int32(16), 'fix');
            d_str(4) = mod(tmp, 16)*8;

            % d_str(1) = idx-1;
            % tmp = idivide(int32(value*1048575), int32(-10), 'fix');
            % d_str(2) = idivide(int32(tmp), int32(8192), 'fix');
            % d_str(3) = idivide(int32(mod(tmp, 8192)), int32(64), 'fix');
            % d_str(4) = mod(tmp, 64)*2;


            % % new method by yugd
            % bitlength = 20;   %for old equip
            % dd_str(1) = idx-1+16;
            % a = round(value*1048576/(-10));
            % b = dec2bin(a);
            % c = length(b);
            % if c<bitlength
            %    for i=1:bitlength - c
            %       b = ['0', b]; 
            %    end
            % end
            % b = [b, '0']; 
            % dd_str(2) = bin2dec(b(1:7));
            % dd_str(3) = bin2dec(b(8:14));
            % dd_str(4) = bin2dec(b(15:21));
            % d_str = dd_str; 
         end
 %% 设置DAC每个通道扫描范围
         function DACsetting = dac_setting(obj)
             % BiasDAC output range initiate
                % -1: -10~0
                %  0:  -5~5
                %  1:   0~10

                % BiasDAC output divider
                %  0:  no div
                %  1:  1/5
                %  2:  1/10

                % KillerFrank, 2011-11-04 11:36

                DACsetting.range(1) = -1;
                DACsetting.range(2) = -1;
                DACsetting.range(3) = -1;
                DACsetting.range(4) = -1;
                DACsetting.range(5) = -1;
                DACsetting.range(6) = -1;
                DACsetting.range(7) = -1;
                DACsetting.range(8) = -1;
                DACsetting.range(9) = -1;
                DACsetting.range(10) = -1;
                DACsetting.range(11) = -1;
                DACsetting.range(12) = 0;

                DACsetting.div(1) = 0;
                DACsetting.div(2) = 0;
                DACsetting.div(3) = 0;
                DACsetting.div(4) = 0;
                DACsetting.div(5) = 0;
                DACsetting.div(6) = 0;
                DACsetting.div(7) = 0;
                DACsetting.div(8) = 0;
                DACsetting.div(9) = 0;
                DACsetting.div(10) = 0;
                DACsetting.div(11) = 0;
                DACsetting.div(12) = 0;
         end
 %% %DAC初始化
         function init_dac(obj)
             % KillerFrank, 2011-11-04 11:36

            tmp = [255, 131]; % 0xFF 0x83, new BiasDAC
            % tmp = [255, 128]; % 0xFF 0x80, old BiasDAC

            fwrite(obj.fs, tmp);
            % tmpstr = fread(fs, 3);      % v1, v2
            tmpstr = fread(obj.fs, 4);      % v3
            % tmpstr1 = fread(fs, 1);      % v3?
            % tmpstr2 = fread(fs, 2);
            % tmpstr3 = fread(fs, 3); 
            % tmpstr4 = fread(fs, 4); 
            % tmpstr5 = fread(fs, 5); 
            % tmpstr6 = fread(fs, 6); 

            obj.rtn_check(tmp(1), tmpstr);

            % fwrite(fs, 63); % reset, old BiasDAC need
            % tmpstr = fread(fs, 2);
         end
 %% 数据采集       
         function data=acquire(obj,idx)
             % read_CH(idx, fs)
            % KillerFrank, 2011-11-04 21:37
            cmdstr = idx-1;
            fwrite(obj.fs, cmdstr);
            % tmpstr = fread(obj.fs, 5);            % v1, v2
            tmpstr = fread(obj.fs, 6);            % v3
            obj.rtn_check(cmdstr, tmpstr);

            data = obj.str2value(tmpstr);

            DACsetting = obj.dac_setting;

            if (DACsetting.range(idx) == 0)
                data = data+5;
            else if (DACsetting.range(idx) == 1)
                    data = data+10;
                end
            end

            if (DACsetting.div(idx) == 1) 
                data = data/5;
            else if (DACsetting.div(idx) == 2)
                    data = data/11;
                end
            end 
         end
         
 %% 设置参数
         function setVoltage(obj,idx,value)
             DACsetting = obj.dac_setting;
            if (DACsetting.div(idx) == 1) 
                value = value*5;
            else if (DACsetting.div(idx) == 2)
                    value = value*11;
                end
            end

            if (DACsetting.range(idx) == 0)
                value = value-5;
            else if (DACsetting.range(idx) == 1)
                    value = value-10;
                end
            end


            cmdstr = obj.value2str(idx, value);
            fwrite(obj.fs, cmdstr);
            % disp('<-');
            % disp(cmdstr);
            % tmpstr = fread(fs, 5);             % v1, v2
            tmpstr = fread(obj.fs, 6);             % v3
            % disp('->');
            % disp(tmpstr');
            obj.rtn_check(idx-1+16, tmpstr);
         end
 %% 解除串口占用
        function delete(obj)
            fclose(obj.fs);
            delete(obj.fs);
        end
         
    end
end