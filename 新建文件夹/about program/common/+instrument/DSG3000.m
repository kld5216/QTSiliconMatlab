classdef DSG3000 < instrument.CLAN
    %CHP83732A �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        fs;
    end
    
    methods(Access = public)
        function obj = DSG3000(address)
            obj.fs = instrfind('Type', 'visa-tcpip', 'RsrcName',address, 'Tag', '');
            obj.fs = visa('AGILENT',address);
                obj.rst();
                obj.outputON();
        end
        %% ������ʼ��
        function rst(obj)
            fprintf(obj.fs,'*RST');
        end
        
% ��һ��ʵ��        
%         function mode_select(obj,type)
%             switch type
%                 case 'holdon'
%                 case 'normal'
%                     obj.rst();
%                     obj.outputON();
%                 case 'pulse'                
%                     obj.rst();
%                     fprintf(obj.fs,':PULM:SOUR EXT');%ѡ�����ԴΪ�ⲿ����
%                     fprintf(obj.fs,':PULM:STAT ON');%��������ƿ���
%                     fprintf(obj.fs,':MOD:STAT ON');%�򿪵������
%                     obj.outputON();
%                 otherwise
%                     errorlog('û�����ģʽ ���� : holdon normal pulse');
%                 
%             end
%         end

%%  �����
        function outputON(obj)
            fprintf(obj.fs,':OUTP ON');
        end
%% �ر����        
        function outputOFF(obj)
            fprintf(obj.fs,':OUTP OFF');
        end
%% �趨Ƶ��        
        function setFreq(obj,freq)
            fprintf(obj.fs,'FREQ %g',freq);
        end
%% �趨����        
        function setPower(obj,power)
            fprintf(obj.fs,'LEV %gdBm',power);
        end
%% �趨��λ
        function setPhase(obj,phase)
            %-720deg~720deg
            fprintf(obj.fs,':SOURce:PHASe %g',phase);
        end
%% �ر���        
        function delete(obj)
            obj.outputOFF();
            pause(0.1);
            fclose(obj.fs);
        end
    end
    
    methods(Access = protected)
        
    end
    
end