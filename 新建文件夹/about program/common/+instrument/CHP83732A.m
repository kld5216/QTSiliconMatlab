classdef CHP83732A < instrument.CGPIB
    %CHP83732A 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
    end
    
    methods
        function obj = CHP83732A(address,varargin)%第二个参数是初始化模式
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
                    fprintf(obj.instObj,':PULM:SOUR EXT');%选择调制源为外部脉冲
                    fprintf(obj.instObj,':PULM:STAT ON');%打开脉冲调制开关
%                     fprintf(obj.instObj,':MOD:STAT ON');%打开调制输出
                    obj.outputON();
                else
                    errorMsg('没有这个模式 尝试 : holdon normal pulse');
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



