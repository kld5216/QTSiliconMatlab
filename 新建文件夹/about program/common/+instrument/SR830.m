classdef SR830 < handle
    % lt<chenbaobao 2018.11.14
    properties
        fs;
        current_input=1;%0 for I,1 for V;
    end
   
    methods
        function obj=SR830(address)
            % GPIB/LAN
            obj.fs=instrfind('Type', 'visa-tcpip', 'RsrcName',address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            
%cbb
%             if length(address) == 3
%                 obj.fs=gpib(address{1},address{2},address{3});
%             elseif length(address) == 2
%                 obj.fs=visa(address{1},address{2});
%             end

            fopen(obj.fs);
            obj.current_input=check_input_mode(obj);
        end       
        
        function delete(obj)
             fclose(obj.fs);
             delete(obj.fs);
        end
        
%% 测量信号               
        function I_read=read_current(obj,type)% X:1 Y:2 R:3 Theta:4
           success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, num2str(type, 'OUTP ? %d\n'));
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end
           I_read = str2double(fscanf(obj.fs));
        end
%% AUX read
        function V_read=read_aux(obj,channel)
          success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, num2str(channel, 'AUXV? %d\n'));
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end
           V_read = str2double(fscanf(obj.fs));      
        end
%% AUX set         
        function write_aux(obj,channel,value)
          command=sprintf('AUXV %d,%f\n',channel,value);
          success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, command);
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end    
        end
%% AUX 逐步        
        function init_aux(obj,channel,value,step,delay)
            current_value=obj.read_aux(channel);
            abs_step=abs(step);
            if current_value>value
                while current_value-value>abs_step
                    current_value=current_value-abs_step;
                    obj.write_aux(channel,current_value);
                    pause(delay);
                end
            else
                while value-current_value>abs_step
                    current_value=current_value+abs_step;
                    lockin.write_aux(channel,current_value);
                    pause(delay);
                end
            end
            obj.write_aux(channel,value);           
        end
%% freqency read       
        function freq=read_freq(obj)
            success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, 'FREQ?\n');
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end
           freq = str2double(fscanf(obj.fs)); 
        end
%% frequency set        
        function write_freq(obj,freq)
           command=sprintf('FREQ %f\n',freq);
          success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs,command);
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end    
        end
%% AMP(输入电压)read  
        function amp=read_amp(obj)
            success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, 'SLVL?\n');
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end
           amp = str2double(fscanf(obj.fs)); 
        end
%% AMP write         
        function write_amp(obj,amp)
            command=sprintf('SLVL %f\n',amp);
          success_flag = 0;
           while success_flag == 0
              try 
                success_flag = 1;
                fprintf(obj.fs, command);
              catch exception
                 if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                    success_flag = 0;
                    disp([datestr(now), ' : ', exception.message]);
                    pause(2);
                 else
                    rethrow(exception);
                 end
              end
           end    
        end
%% 
        function status=check_output_overload(obj)
            fprintf(obj.fs,'LIAS? 2\n');
            fscanf(obj.fs);
            fprintf(obj.fs,'LIAS? 2\n');
            status=str2double(fscanf(obj.fs));
        end
%% sens       
        function sens=read_sens(obj)
             fprintf(obj.fs,'SENS?\n');
             sens=str2double(fscanf(obj.fs));
        end
        function write_sens(obj,sens)
            fprintf(obj.fs,'SENS %d\n',sens);
        end
%%        
        function mode=check_input_mode(obj)
            fprintf(obj.fs,'ISRC?');
            r=str2double(fscanf(obj.fs));
            if r==0||r==1
                mode=1;
            else
                mode=0;
            end
        end
        function  set_input_mode(obj,mode)
             fprintf(obj.fs,'ISRC %d',mode);
        end
        function rtheta=snapRtheta(obj)
            fprintf(obj.fs,'SNAP?3,4\n');
            r=fscanf(obj.fs);
            p=textscan(r,'%f','Delimiter',',');
            rtheta=p{1};
        end
    end
end
	