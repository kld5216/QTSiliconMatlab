classdef MicrowaveSource < handle
    %CHP83732A/Keisight 均可使用(共有基础功能)
    % lt 2018.11.14<JZL    
    properties
        fs;        
    end
    
    methods
        function obj = MicrowaveSource(address)%第二个参数是初始化模式
            % GPIB/LAN
            obj.fs=instrfind('Type', 'visa-tcpip', 'RsrcName',address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            fopen(obj.fs);
            obj.rst();
%             obj.outputON();           
        end
        
        function rst(obj)
            fprintf(obj.fs,'*RST');
        end
%% 开关        
        function outputON(obj)
            fprintf(obj.fs,':OUTPUT ON');
        end
        function outputOFF(obj)
            fprintf(obj.fs,':OUTPUT OFF');
        end
%% 设置频率        
        function setFreq(obj,freq)
            fprintf(obj.fs,'frequency %g',freq);
        end
%% 设置功率       
        function setPower(obj,power)
            fprintf(obj.fs,'power %g',power);
        end
        function delete(obj)
            obj.outputOFF();
            pause(0.1);
            fclose(obj.fs);
        end
    end
    
end



