classdef CE5071C < handle
    %CE5071C �˴���ʾ�йش����ժҪ    
    %lt 2018.11.20 v1.01
    
    properties
        fs;
    end
    
    methods
        function obj = CE5071C(address)
            obj.fs = instrfind('Type', 'visa-tcpip', 'RsrcName', address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            set(obj.fs, 'InputBufferSize', 102400);%���û�������С
            fopen(obj.fs);
        end
%% set ���on
        function outputON(obj)                        
            fprintf(obj.fs,':OUTP ON');
        end
%% set ��� off
        function outputOFF(obj)
            fprintf(obj.fs,':OUTP OFF');
        end
%% ���ù���                
        function setPower(obj,value)
            fprintf(obj.fs,':SOUR1:POW %g',value);
        end
%% ����ɨ��Ƶ�ʷ�Χ        
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
%% ��������Ƶ�ʣ�ɨ���ʵ�ʱ��        
        function setCenterFreq(obj,cent)
            fprintf(obj.fs,':SENS1:FREQ:CENT %g',cent);
        end
%% ���ù��ʣ�ɨƵ��ʱ��       
        function setCenterPower(obj,cent)
            fprintf(obj.fs,':SOUR1:POW:CENT %g',cent);
        end
%% ����Ƶ�ʷ�Χ��ȣ�һ�㲻�ã�
        function setBandWidth(obj,span)
            fprintf(obj.fs,':SENS1:FREQ:SPAN %g',span);
        end
%% ������Ƶ����
        function setIFBW(obj,IFBW)
            fprintf(obj.fs,':SENS1:BAND %g',IFBW);
        end
%% ���ζ�ȡ��ʱ����ɨһ��Ƶ��Ȼ��ֹͣ����Ϊ���ߴ���
        function singleTrig(obj)
            fprintf(obj.fs,':INIT1:CONT 0');
            fprintf(obj.fs,':TRIG:SOUR BUS');%�趨ϵͳ����ģʽ
            fprintf(obj.fs,':INIT1');
            fprintf(obj.fs,':TRIG:SING');
            while obj.isMeasuring()
            end
        end
%% �����һ��ֹͣ״̬ ��Ϊ�ڲ�����        
        function singleTrigRst(obj)
            fprintf(obj.fs,':INIT1:CONT 1');
            fprintf(obj.fs,':TRIG:SOUR INT');
        end
%% �Ƿ��ڲ��������ԣ�         
        function answer = isMeasuring(obj)
            runState = query(obj.fs,':STAT:OPER:COND?');
            runState = str2num(runState);
            if bitand(runState,16)~= 0
                answer = true;
            else
                answer = false;
            end
        end
%% read_Freqlist������Ƶ�����飩
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
%% read_Point ����ɨ�践��
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
            %��polarģʽ�Ļ�Line��ֻʣ�����㣬����һ�㶼Ҫ����num
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

