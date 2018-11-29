classdef instr_ITEK<instrument.CITEK
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    
    properties
        ch={};
        ch_name={};
        operate_type={};% 'read'/'set'/'both'/'ban' useless=ban 在itek中不存在明确区分 ch ch_name operate_type 三者为拓展类函数的必备要素
        %% ITEK因为要保护样品，所以有变化保留设置
        limit_min=-10;
        limit_max=2;
        step=0.05;%最大每次下降幅度
        delay=0.1;%下降后暂停
    end
    
    methods
        function obj =instr_ITEK(server_ip,instrument_parameter)
            %通过 instrument_parameter配置ITECK
            %eg:instrument_parameter=ITEK.txt
            obj=obj@instrument.CITEK(server_ip);
           %% 通过配置文件读取
            fid=fopen(instrument_parameter);% eg:instrument_parameter='.\Defaults_para\Defaults_setting\instrument_parameter\ITEK.txt'            
            for i=1:16
                tline=fgetl(fid);
                str=strsplit(tline,' ');
                obj.ch{i}=str{1};
                obj.ch_name{i}=str{2};
                %% ITEK类只有禁止与both 因此规范简化
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
        %% 主功能函数
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
                    %成功设置返回1
                    if (nargin>3)
                        out_put=itek_set(obj,varargin);
                    else
                        error('wrong instr_ITEK set parameter number!');
                    end
                otherwise
                    error('wrong instr_ITEK operate type');
            end
        end
      %% 功能函数（基于CITEK）      
        function out_put=itek_read(obj,idx)
            out_put=acquire(obj,idx);
        end
        
        function out_put=itek_set(obj,varargin)
            % varargin={{idx,value,step,delay}}            
            varargin=varargin{1};%参数传递去元胞化
            % varargin={idx,value,{step,delay}} 或
            % varargin={idx,value,'direct'} 'direct'直接变到设定值                       
            idx=varargin{1};
            value=varargin{2};
            
            %用于实现直接设置功能
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
                return;%跳出                
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
            %% 更改电压
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
                error();%这才是真正的中断程
            end
        end
    end
end

%% 原始类 2018年LT版
%
% classdef CITEK < handle
%     %CITEK 此处显示有关此类的摘要
%     %电压源共有16个电压输出 使用1~6为U1~U6 8~13 为D1~D6
%
%     properties
%         fs;%操作句柄
%         BaudRate=115200;%该串口向仪器输入的波特率，这个是个固定的
%         Terminator=13;
%     end
%
%     methods
%         function obj = CITEK(server_ip)
%               obj.fs=serial(server_ip);
%               obj.fs.BaudRate=obj.BaudRate;
%               obj.fs.Terminator=obj.Terminator;
%               fopen(obj.fs);%用于打开操作句柄
%         end
% %% 采集数据
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
% %% 设置参数
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
% %% 解除串口占用
%         function delete(obj)
%             fclose(obj.fs);
%             delete(obj.fs);
%         end
%     end
% end

