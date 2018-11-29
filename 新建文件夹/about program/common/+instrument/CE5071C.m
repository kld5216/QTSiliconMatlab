classdef CE5071C < handle
    %CE5071C 此处显示有关此类的摘要    
    %lt 2018.11.20 v1.01
    
    properties
        fs;
    end
    
    methods
        function obj = CE5071C(address)
            obj.fs = instrfind('Type', 'visa-tcpip', 'RsrcName', address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            set(obj.fs, 'InputBufferSize', 102400);%设置缓冲区大小
            fopen(obj.fs);
        end
%% set 输出on
        function outputON(obj)                        
            fprintf(obj.fs,':OUTP ON');
        end
%% set 输出 off
        function outputOFF(obj)
            fprintf(obj.fs,':OUTP OFF');
        end
%% 设置功率                
        function setPower(obj,value)
            fprintf(obj.fs,':SOUR1:POW %g',value);
        end
%% 设置扫描频率范围        
        function setScanFreq(obj,start,stop)
            fprintf(obj.fs,':SENS1:FREQ:STAR %g',start);
            fprintf(obj.fs,':SENS1:FREQ:STOP %g',stop);
        end
        function setScanFreq_star(obj,start)
            fprintf(obj.fs,':SENS1:FREQ:STAR %g',start);
        end
        function setScanFreq_end(obj,stop)
            fprintf(obj.fs,':SENS1:FREQ:STAR %g',stop);
        end
%% 设置中心频率（扫功率的时候）        
        function setCenterFreq(obj,cent)
            fprintf(obj.fs,':SENS1:FREQ:CENT %g',cent);
        end
%% 设置功率（扫频的时候）       
        function setCenterPower(obj,cent)
            fprintf(obj.fs,':SOUR1:POW:CENT %g',cent);
        end
%% 设置频率范围宽度（一般不用）
        function setBandWidth(obj,span)
            fprintf(obj.fs,':SENS1:FREQ:SPAN %g',span);
        end
%% 设置中频带宽
        function setIFBW(obj,IFBW)
            fprintf(obj.fs,':SENS1:BAND %g',IFBW);
        end
%% 单次读取（时候后会扫一次频率然后停止）换为总线触发
        function singleTrig(obj)
            fprintf(obj.fs,':INIT1:CONT 0');
            fprintf(obj.fs,':TRIG:SOUR BUS');%设定系统触发模式
            fprintf(obj.fs,':INIT1');
            fprintf(obj.fs,':TRIG:SING');
            while obj.isMeasuring()
            end
        end
%% 解除上一个停止状态 换为内部触发        
        function singleTrigRst(obj)
            fprintf(obj.fs,':INIT1:CONT 1');
            fprintf(obj.fs,':TRIG:SOUR INT');
        end
%% 是否在测量（忽略）         
        function answer = isMeasuring(obj)
            runState = query(obj.fs,':STAT:OPER:COND?');
            runState = str2num(runState);
            if bitand(runState,16)~= 0
                answer = true;
            else
                answer = false;
            end
        end
%% read_Freqlist（测量频率数组）
        function FreqList = getFreqList(obj)
            FreqListStr = query(obj.fs,':SENS1:FREQ:DATA?');
            FreqList = str2num(FreqListStr);
            FreqList = FreqList';
        end        
%% read_Amp        
        function AmpList = getAmpList(obj)
%             fprintf(obj.fs,':CALC1:FORM MLOG');
            fprintf(obj.fs,':CALC1:FORM MLIN');
            AmpListStr = query(obj.fs,':CALC1:DATA:FDAT?');
            data = str2num(AmpListStr);
            data = data';
            AmpList = data(1:2:end);
        end
        
%% read_Phase MLOG
        function PhaseList = getPhaseList(obj)
            fprintf(obj.fs,':CALC1:FORM PHAS');
            PhaseListStr = query(E5071C,':CALC1:DATA:FDAT?');
            fprintf(obj.fs,':CALC1:FORM MLOG');
%             fprintf(obj.fs,':CALC1:FORM MLIN');
            data = str2num(PhaseListStr);
            data = data';
            PhaseList = data(1:2:end);
        end
%% read_Phase MLIN
        function ExtPhaseList = getExtPhaseList(obj)
            fprintf(obj.fs,':CALC1:FORM UPH');
            ExtPhaseListStr = query(obj.fs,':CALC1:DATA:FDAT?');
%             fprintf(obj.fs,':CALC1:FORM MLOG');
            fprintf(obj.fs,':CALC1:FORM MLIN');
            data = str2num(ExtPhaseListStr);
            data = data';
            ExtPhaseList = data(1:2:end);
        end        
%% read_Point 功率扫描返回
        function [amp,phase] = getPoint(obj)
            datastr = query(obj.fs,':CALC1:MARK1:Y?');
            data = str2num(datastr);
            amp = data(1,1);
            phase = data(1,2);
        end
%% read_Point_freq       
        function freq = getMark1X(obj)
            datastr = query(obj.fs,':CALC1:MARK1:X?');
            freq = str2num(datastr);
        end
%%         
        function saveState(obj,varargin)
            if(nargin==1)
                order = ':MMEM:STOR:CHAN A';
            elseif(nargin==2)
                order = [':MMEMory:STORe:STATe ','"',varargin{1},'"'];
            end
            fprintf(obj.fs,order);
        end
        function loadState(obj,varargin)
            if(nargin==1)
                order = ':MMEM:LOAD:CHAN A';
            elseif(nargin==2)
                order = [':MMEMory:LOAD:STATe ','"',varargin{1},'"'];
            end
            fprintf(obj.fs,order);
        end
        function delete(obj)
%             fprintf(obj.fs,':TRIG:SOUR INT');
%             fprintf(obj.fs,':INIT1:CONT 1');
            fclose(obj.fs);
            delete(obj);
            
        end
        
        function setPolar(obj)
            fprintf(obj.fs,':CALC1:FORM PLIN');
            fprintf(obj.fs,':SENS1:SWE:POIN %g',2);
            fprintf(obj.fs,':SENS1:SWE:TYPE POW');
        end
           
        
        function setLin(obj,varargin)
            %由polar模式改回Line会只剩两个点，所以一般都要输入num
            if ~isempty(varargin)
                num=varargin{1};
                fprintf(obj.fs,':SENS1:SWE:POIN %g',num);
            end
            fprintf(obj.fs,':SENS1:SWE:TYPE LIN');
            fprintf(obj.fs,':CALC1:FORM MLIN');            
            
%             fprintf(obj.fs,':SENS1:SWE:POIN %g',num);
        end
    end
    
   methods(Access = private) 
       function hello(~)
           disp('heool');
       end
   end
end

