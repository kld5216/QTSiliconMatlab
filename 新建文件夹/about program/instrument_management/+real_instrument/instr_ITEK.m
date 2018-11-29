classdef instr_ITEK<instrument.CITEK
    %����Ӳ�����ͨһ�����������ɺ����Ͳ�������
    %���ÿ��������������ڱ���Լ�����
    
    properties
        ch={};
        ch_name={};
        operate_type={};% 'read'/'set'/'both'/'ban' useless=ban ��itek�в�������ȷ���� ch ch_name operate_type ����Ϊ��չ�ຯ���ıر�Ҫ��
        %% ITEK��ΪҪ������Ʒ�������б仯��������
        limit_min=-10;
        limit_max=2;
        step=0.05;%���ÿ���½�����
        delay=0.1;%�½�����ͣ
    end
    
    methods
        function obj =instr_ITEK(server_ip,instrument_parameter)
            %ͨ�� instrument_parameter����ITECK
            %eg:instrument_parameter=ITEK.txt
            obj=obj@instrument.CITEK(server_ip);
           %% ͨ�������ļ���ȡ
            fid=fopen(instrument_parameter);% eg:instrument_parameter='.\Defaults_para\Defaults_setting\instrument_parameter\ITEK.txt'            
            for i=1:16
                tline=fgetl(fid);
                str=strsplit(tline,' ');
                obj.ch{i}=str{1};
                obj.ch_name{i}=str{2};
                %% ITEK��ֻ�н�ֹ��both ��˹淶��
                if strcmp(obj.ch_name{i},'USELESS')||strcmp(obj.ch_name{i},'ban')
                    obj.operate_type{i}='ban';
                else
                    obj.operate_type{i}='both';
                end
            end
            obj.limit_max=str2num(fgetl(fid));
            obj.limit_min=str2num(fgetl(fid));
            obj.step=str2num(fgetl(fid));
            obj.delay=str2num(fgetl(fid));
            fclose(fid);
        end
        %% �����ܺ���
        function out_put= operate(obj,type,varargin)
            %operate('read',idx);
            %operate('set',idx,value{,step,delay});
            switch type
                case 'read'
                    if (nargin==3)
                        out_put=itek_read(obj,varargin{1});
                    else
                        error('wrong instr_ITEK read parameter number!');
                    end
                case 'set'
                    %�ɹ����÷���1
                    if (nargin>3)
                        out_put=itek_set(obj,varargin);
                    else
                        error('wrong instr_ITEK set parameter number!');
                    end
                otherwise
                    error('wrong instr_ITEK operate type');
            end
        end
      %% ���ܺ���������CITEK��      
        function out_put=itek_read(obj,idx)
            out_put=acquire(obj,idx);
        end
        
        function out_put=itek_set(obj,varargin)
            % varargin={{idx,value,step,delay}}            
            varargin=varargin{1};%��������ȥԪ����
            % varargin={idx,value,{step,delay}} ��
            % varargin={idx,value,'direct'} 'direct'ֱ�ӱ䵽�趨ֵ                       
            idx=varargin{1};
            value=varargin{2};
            
            %����ʵ��ֱ�����ù���
            if (length(varargin)==3)&&(strcmp(class(varargin{3}),'char'))
                if strcmp(varargin{3},'direct')
                    obj.cheak_value(idx,value);
                    obj.setVoltage(idx,value);
                    out_put=1;
                else
                    str_error='wrong instr_ITEK operate ?direct?num?idx? !';
                    errordlg(str_error,'ITEK_Error');
                    out_put=0;
                end
                return;%����                
            end            
            
            if (length(varargin)>=3)
                change_step=varargin{3};
            else
                change_step=obj.step;
            end
            if (length(varargin)>=4)
                change_delay=varargin{4};
            else
                change_delay=obj.delay;
            end
            %% ���ĵ�ѹ
            Now_value=itek_read(obj,idx);
            if (Now_value~=value)
                obj.cheak_value(idx,value);
                change_step=abs(change_step);
                if (Now_value>value) change_step=-change_step;end
                for i=Now_value:change_step:value
                    obj.setVoltage(idx,i);
                    pause(change_delay);
                end
                obj.setVoltage(idx,value);
            end
            out_put=1;
        end
        
        function cheak_value(obj,idx,value)
            if  (value<obj.limit_min)||(value>obj.limit_max)
                str_error=strcat('Voltage range is [',num2str(obj.limit_min),',',num2str(obj.limit_max),'] Input idx:',num2str(idx),'(',num2str(value),'V) is illegal');
                errordlg(str_error,'ITEK_Error');
                error();%������������жϳ�
            end
        end
    end
end

%% ԭʼ�� 2018��LT��
%
% classdef CITEK < handle
%     %CITEK �˴���ʾ�йش����ժҪ
%     %��ѹԴ����16����ѹ��� ʹ��1~6ΪU1~U6 8~13 ΪD1~D6
%
%     properties
%         fs;%�������
%         BaudRate=115200;%�ô�������������Ĳ����ʣ�����Ǹ��̶���
%         Terminator=13;
%     end
%
%     methods
%         function obj = CITEK(server_ip)
%               obj.fs=serial(server_ip);
%               obj.fs.BaudRate=obj.BaudRate;
%               obj.fs.Terminator=obj.Terminator;
%               fopen(obj.fs);%���ڴ򿪲������
%         end
% %% �ɼ�����
%         function data = acquire(obj,idx)
%             switch idx
%                case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
%                    cmd=sprintf('R%x',idx-1);
%                    fprintf(obj.fs,'%s\n',cmd);
%                    data=str2double(fscanf(obj.fs));
%                otherwise
%                    error('wrong itek channel');
%             end
%         end
% %% ���ò���
%         function setVoltage(obj,idx,value)
%             switch idx
%                case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
%                    cmd=sprintf('S%x%g',idx-1,value);
%                    fprintf(obj.fs,'%s\n',cmd);
%                    fscanf(obj.fs);
%                otherwise
%                    error('wrong itek channel');
%             end
%         end
% %% �������ռ��
%         function delete(obj)
%             fclose(obj.fs);
%             delete(obj.fs);
%         end
%     end
% end

