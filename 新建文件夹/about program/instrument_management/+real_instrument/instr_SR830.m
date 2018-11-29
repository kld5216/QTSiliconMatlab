classdef instr_SR830<instrument.SR830
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %ch_name operate_type 三者为拓展类函数的必备要素
        ch={};
        ch_name={};
        operate_type={};% 'read'/'set'/'both'/'ban' useless=ban
        
        %         limit_min=-10;
        %         limit_max=2;
        %         step=0.05;%最大每次下降幅度
        %         delay=0.1;%下降后暂停
    end
    
    
    methods
        function obj = instr_SR830(address,instrument_parameter)
            %通过 instrument_parameter配置SR830
            %eg:instrument_parameter=SR830.txt
            obj=obj@instrument.SR830(address);
            %% 通过配置文件读取
            fid=fopen(instrument_parameter);% eg:instrument_parameter='.\Defaults_para\Defaults_setting\instrument_parameter\SR830.txt'
            for i=1:11
                tline=fgetl(fid);
                str=strsplit(tline,' ');
                obj.ch{i}=str{1};
                obj.ch_name{i}=str{2};
                obj.operate_type{i}=str{3};
            end
        end
        %% 主功能函数
        function out_put= operate(obj,type,varargin)
            %operate('read',idx);
            %operate('set',idx,value{,step,delay});
            if (obj.operate_check(type,varargin{1}))
                if strcmp(type,'read')
                    out_put=obj.SR830_read(varargin{1});
                end
                if strcmp(type,'set')
                    if (length(varargin)>1)
                        out_put=obj.SR830_set(varargin);
                    else
                        str_error='wrong instr_SR830 set parameter number!';
                        errordlg(str_error,'SR830_Error');
                    end
                end
            end
        end
        %% 功能函数（基于SR830）
        function out_put=SR830_read(obj,idx)
            switch idx
                case 1 %I_x(read only)
                    out_put=obj.read_current(1);
                case 2 %I_y(read only)
                    out_put=obj.read_current(2);
                case 3 %Lockin_I(read only)
                    out_put=obj.read_current(3);
                case 4 %Lockin_Theta(read only)
                    out_put=obj.read_current(4);
                case 5 %Aux1
                    out_put=obj.read_aux(1);
                case 6 %Aux2
                    out_put=obj.read_aux(2);
                case 7 %Aux3
                    out_put=obj.read_aux(3);
                case 8 %Aux4
                    out_put=obj.read_aux(4);
                case 9 %Lockin_Freq
                    out_put=obj.read_freq;
                case 10 %Lockin_Amp
                    out_put=obj.read_amp;
                case 11 %sens
                    out_put=obj.read_sens;
                otherwise
                    str_error=strcat('operate idx out of range! ',num2str(idx));
                    errordlg(str_error,'SR830_Error');
                    out_put=0;
            end
        end
        
        function out_put=SR830_set(obj,varargin)
            % varargin={{idx,value,step,delay}}
            varargin=varargin{1};%参数传递去元胞化
            % varargin={idx,value,{step,delay}} 或
            % varargin={idx,value,'direct'}
            % 'direct'直接变到设定值，该程序不设’direct'也是直接跳的
            idx=varargin{1};
            value=varargin{2};
            
            %用于实现直接设置功能
            if ((length(varargin)==2)||((length(varargin)==3)&&(ischar(varargin{3}))
                if (length(varargin)==2)||strcmp(varargin{3},'direct')
                    %                     obj.cheak_value(idx,value);
                    obj.subset(idx,value);
                    out_put=1;
                else
                    str_error='wrong instr_SR830 operate ?direct?num?idx? !';
                    errordlg(str_error,'SR830_Error');
                    out_put=0;
                end
                return;%跳出
            end
            
            if (length(varargin)>=3)
                change_step=varargin{3};
            end
            if (length(varargin)>=4)
                change_delay=varargin{4};
            else
                change_delay=0.1;
            end
            %% 更改电压
            Now_value=obj.SR830_read(idx);
            if (Now_value~=value)
                %                 obj.cheak_value(idx,value);
                change_step=abs(change_step);
                if (Now_value>value)
                    change_step=-change_step;
                end
                for i=Now_value:change_step:value
                    obj.subset(idx,i);
                    pause(change_delay);
                end
                obj.subset(idx,value);
            end
            out_put=1;
        end
        
        function out_put=subset(obj,idx,value)
            switch idx
                case 1 %I_x(read only)
                case 2 %I_y(read only)
                case 3 %Lockin_I(read only)
                case 4 %Lockin_Theta(read only)
                case 5 %Aux1
                    obj.write_aux(1,value);
                case 6 %Aux2
                    obj.write_aux(2,value);
                case 7 %Aux3
                    obj.write_aux(3,value);
                case 8 %Aux4
                    obj.write_aux(4,value);
                case 9 %Lockin_Freq
                    obj.write_freq(value);
                case 10 %Lockin_Amp
                    obj.write_amp(value);
                case 11 %sens
                    obj.write_sens(value);
                otherwise
                    str_error=strcat('operate idx out of range! ',num2str(idx));
                    errordlg(str_error,'SR830_Error');                    
            end
            out_put=1;
        end
        
        %% 操作是否被禁用
        function out_put=operate_check(obj,type,idx)
            % right/wrong 1/0
            if ~(strcmp(type,'set')||strcmp(type,'read'))
                out_put=0;
                str_error=strcat('Input operate type is wrong!');
                errordlg(str_error,'SR830_Error');
                return;
            end
            switch obj.operate_type{idx}
                case 'ban'
                    out_put=0;
                    str_error=strcat(obj.ch{idx},' is ban!');
                    errordlg(str_error,'SR830_Error');
                    return;
                case 'both'
                    out_put=1;
                case 'read'
                    out_put=strcmp(type,obj.operate_type{idx});
                    if (~out_put)
                        out_put=0;
                        str_error=strcat(obj.ch{idx},' is only read!');
                        errordlg(str_error,'SR830_Error');
                        return;
                    end
                case 'set'
                    out_put=strcmp(type,obj.operate_type{idx});
                    if (~out_put)
                        out_put=0;
                        str_error=strcat(obj.ch{idx},' is only set!');
                        errordlg(str_error,'SR830_Error');
                        return;
                    end
                otherwise
                    out_put=0;
                    str_error=strcat(obj.ch{idx},' opreate type is illegal! ',obj.operate_type{idx});
                    errordlg(str_error,'SR830_Error');
                    return;
            end
        end
        %% 检查输入值函数（未使用）
        %         function cheak_value(obj,idx,value)
        %             %             if  (value<obj.limit_min)||(value>obj.limit_max)
        %             %                 str_error=strcat('Voltage range is [',num2str(obj.limit_min),',',num2str(obj.limit_max),'] Input idx:',num2str(idx),'(',num2str(value),'V) is illegal');
        %             %                 errordlg(str_error,'ITEK_Error');
        %             %                 error();%这才是真正的中断程序
        %             %             end
        %         end
    end
end

%% 原始SR830类 2018年版
% classdef SR830 < handle
%     % lt<chenbaobao 2018.11.14
%     properties
%         fs;
%         current_input=1;%0 for I,1 for V;
%     end
%
%     methods
%         function obj=SR830(address)
%             % GPIB
%             obj.fs=instrfind('Type', 'visa-tcpip', 'RsrcName',address, 'Tag', '');
%             obj.fs=visa('AGILENT',address);
%
% %cbb
% %             if length(address) == 3
% %                 obj.fs=gpib(address{1},address{2},address{3});
% %             elseif length(address) == 2
% %                 obj.fs=visa(address{1},address{2});
% %             end
%
%             fopen(obj.fs);
%             obj.current_input=check_input_mode(obj);
%         end
%
%         function delete(obj)
%              fclose(obj.fs);
%              delete(obj.fs);
%         end
%
% %% 测量信号
%         function I_read=read_current(obj,type)% X:1 Y:2 R:3 Theta:4
%            success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, num2str(type, 'OUTP ? %d\n'));
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%            I_read = str2double(fscanf(obj.fs));
%         end
% %% AUX read
%         function V_read=read_aux(obj,channel)
%           success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, num2str(channel, 'AUXV? %d\n'));
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%            V_read = str2double(fscanf(obj.fs));
%         end
% %% AUX set
%         function write_aux(obj,channel,value)
%           command=sprintf('AUXV %d,%f\n',channel,value);
%           success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, command);
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%         end
% %% AUX 逐步
%         function init_aux(obj,channel,value,step,delay)
%             current_value=obj.read_aux(channel);
%             abs_step=abs(step);
%             if current_value>value
%                 while current_value-value>abs_step
%                     current_value=current_value-abs_step;
%                     obj.write_aux(channel,current_value);
%                     pause(delay);
%                 end
%             else
%                 while value-current_value>abs_step
%                     current_value=current_value+abs_step;
%                     lockin.write_aux(channel,current_value);
%                     pause(delay);
%                 end
%             end
%             obj.write_aux(channel,value);
%         end
% %% freqency read
%         function freq=read_freq(obj)
%             success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, 'FREQ?\n');
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%            freq = str2double(fscanf(obj.fs));
%         end
% %% frequency set
%         function write_freq(obj,freq)
%            command=sprintf('FREQ %f\n',freq);
%           success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs,command);
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%         end
% %% AMP(输入电压)read
%         function amp=read_amp(obj)
%             success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, 'SLVL?\n');
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%            amp = str2double(fscanf(obj.fs));
%         end
% %% AMP write
%         function write_amp(obj,amp)
%             command=sprintf('SLVL %f\n',amp);
%           success_flag = 0;
%            while success_flag == 0
%               try
%                 success_flag = 1;
%                 fprintf(obj.fs, command);
%               catch exception
%                  if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
%                     success_flag = 0;
%                     disp([datestr(now), ' : ', exception.message]);
%                     pause(2);
%                  else
%                     rethrow(exception);
%                  end
%               end
%            end
%         end
% %%
%         function status=check_output_overload(obj)
%             fprintf(obj.fs,'LIAS? 2\n');
%             fscanf(obj.fs);
%             fprintf(obj.fs,'LIAS? 2\n');
%             status=str2double(fscanf(obj.fs));
%         end
% %% sens
%         function sens=read_sens(obj)
%              fprintf(obj.fs,'SENS?\n');
%              sens=str2double(fscanf(obj.fs));
%         end
%         function write_sens(obj,sens)
%             fprintf(obj.fs,'SENS %d\n',sens);
%         end
% %%
%         function mode=check_input_mode(obj)
%             fprintf(obj.fs,'ISRC?');
%             r=str2double(fscanf(obj.fs));
%             if r==0||r==1
%                 mode=1;
%             else
%                 mode=0;
%             end
%         end
%         function  set_input_mode(obj,mode)
%              fprintf(obj.fs,'ISRC %d',mode);
%         end
%         function rtheta=snapRtheta(obj)
%             fprintf(obj.fs,'SNAP?3,4\n');
%             r=fscanf(obj.fs);
%             p=textscan(r,'%f','Delimiter',',');
%             rtheta=p{1};
%         end
%     end
% end

