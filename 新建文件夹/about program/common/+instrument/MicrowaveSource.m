classdef MicrowaveSource < handle
    %CHP83732A/Keisight ����ʹ��(���л�������)
    % lt 2018.11.14<JZL    
    properties
        fs;        
    end
    
    methods
        function obj = MicrowaveSource(address)%�ڶ��������ǳ�ʼ��ģʽ
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
%% ����        
        function outputON(obj)
            fprintf(obj.fs,':OUTPUT ON');
        end
        function outputOFF(obj)
            fprintf(obj.fs,':OUTPUT OFF');
        end
%% ����Ƶ��        
        function setFreq(obj,freq)
            fprintf(obj.fs,'frequency %g',freq);
        end
%% ���ù���       
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



