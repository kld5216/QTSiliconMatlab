classdef CITEK < handle
    %CITEK 此处显示有关此类的摘要
    %电压源共有16个电压输出 使用1~6为U1~U6 8~13 为D1~D6
    
    properties
        fs;
        BaudRate=115200;
        Terminator=13;
    end
    
    methods
        function obj = CITEK(server_ip)
              obj.fs=serial(server_ip);
              obj.fs.BaudRate=obj.BaudRate;
              obj.fs.Terminator=obj.Terminator;
              fopen(obj.fs);%用于打开操作句柄
        end        
%% 采集数据       
        function data = acquire(obj,idx)
            switch idx
               case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
                   cmd=sprintf('R%x',idx-1);
                   fprintf(obj.fs,'%s\n',cmd);
                   data=str2double(fscanf(obj.fs));
               otherwise
                   error('wrong itek channel');
            end
        end
%% 设置参数
        function setVoltage(obj,idx,value)
            switch idx
               case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
                   cmd=sprintf('S%x%g',idx-1,value);
                   fprintf(obj.fs,'%s\n',cmd);
                   fscanf(obj.fs);
               otherwise
                   error('wrong itek channel');
            end
        end
%% 解除串口占用          
        function delete(obj)
            fclose(obj.fs);
            delete(obj.fs);
        end
    end
end

