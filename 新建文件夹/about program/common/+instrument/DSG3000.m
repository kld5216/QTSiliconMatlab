classdef DSG3000 < instrument.CLAN
    %CHP83732A 此处显示有关此类的摘要
    %   此处显示详细说明
    
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
        %% 仪器初始化
        function rst(obj)
            fprintf(obj.fs,'*RST');
        end
        
% 下一级实现        
%         function mode_select(obj,type)
%             switch type
%                 case 'holdon'
%                 case 'normal'
%                     obj.rst();
%                     obj.outputON();
%                 case 'pulse'                
%                     obj.rst();
%                     fprintf(obj.fs,':PULM:SOUR EXT');%选择调制源为外部脉冲
%                     fprintf(obj.fs,':PULM:STAT ON');%打开脉冲调制开关
%                     fprintf(obj.fs,':MOD:STAT ON');%打开调制输出
%                     obj.outputON();
%                 otherwise
%                     errorlog('没有这个模式 尝试 : holdon normal pulse');
%                 
%             end
%         end

%%  打开输出
        function outputON(obj)
            fprintf(obj.fs,':OUTP ON');
        end
%% 关闭输出        
        function outputOFF(obj)
            fprintf(obj.fs,':OUTP OFF');
        end
%% 设定频率        
        function setFreq(obj,freq)
            fprintf(obj.fs,'FREQ %g',freq);
        end
%% 设定功率        
        function setPower(obj,power)
            fprintf(obj.fs,'LEV %gdBm',power);
        end
%% 设定相位
        function setPhase(obj,phase)
            %-720deg~720deg
            fprintf(obj.fs,':SOURce:PHASe %g',phase);
        end
%% 关闭类        
        function delete(obj)
            obj.outputOFF();
            pause(0.1);
            fclose(obj.fs);
        end
    end
    
    methods(Access = protected)
        
    end
    
end