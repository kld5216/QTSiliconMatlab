classdef CITEK < handle
    %CITEK �˴���ʾ�йش����ժҪ
    %��ѹԴ����16����ѹ��� ʹ��1~6ΪU1~U6 8~13 ΪD1~D6
    
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
              fopen(obj.fs);%���ڴ򿪲������
        end        
%% �ɼ�����       
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
%% ���ò���
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
%% �������ռ��          
        function delete(obj)
            fclose(obj.fs);
            delete(obj.fs);
        end
    end
end

