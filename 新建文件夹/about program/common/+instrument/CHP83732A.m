classdef CHP83732A < instrument.CGPIB
    %CHP83732A �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
    end
    
    methods
        function obj = CHP83732A(address,varargin)%�ڶ��������ǳ�ʼ��ģʽ
            obj = obj@instrument.CGPIB(address);
            if(nargin==1)
                obj.rst();
                obj.outputON();
            else
                if(strcmp(varargin{1},'holdon'))

                elseif(strcmp(varargin{1},'normal'))
                    obj.rst();
                    obj.outputON();
                elseif(strcmp(varargin{1},'pulse'))
                    obj.rst();
                    fprintf(obj.instObj,':PULM:SOUR EXT');%ѡ�����ԴΪ�ⲿ����
                    fprintf(obj.instObj,':PULM:STAT ON');%��������ƿ���
%                     fprintf(obj.instObj,':MOD:STAT ON');%�򿪵������
                    obj.outputON();
                else
                    errorMsg('û�����ģʽ ���� : holdon normal pulse');
                end
            end
        end
        
        function rst(obj)
            fprintf(obj.instObj,'*RST');
        end
        
        function outputON(obj)
            fprintf(obj.instObj,':OUTPUT ON');
        end
        function outputOFF(obj)
            fprintf(obj.instObj,':OUTPUT OFF');
        end
        function setFreq(obj,freq)
            fprintf(obj.instObj,'frequency %g',freq);
        end
        function setPower(obj,power)
            fprintf(obj.instObj,'power %g',power);
        end
        function delete(obj)
            obj.outputOFF();
            pause(0.1);
            fclose(obj.instObj);
        end
    end
    
end



