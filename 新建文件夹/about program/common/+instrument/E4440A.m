classdef E4440A<handle
    % Agilent Ƶ����
    % 2018.11.23 by lt
    properties
        fs;
    end
    
    methods
        function obj = E4440A(address)
            %��������ʵ��
            obj.fs = instrfind('Type', 'visa-tcpip', 'RsrcName', address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            %GPIB����
            fopen(obj.fs);
        end
        %% ��������Ƶ��
        function set_Center_Frq(obj,frq)
            fprintf(obj.fs,':SENSe:FREQuency:CENTer %d',frq);
        end
        %% ����Ƶ�ʿ��
        function set_Frq_Span(obj,span)
            fprintf(obj.fs,':SENSe:FREQuency:SPAN %d',span);
        end
        %% ��Y������
        function out_put=read_Y(obj)
            out_put=str2num(query(obj.fs,':CALC:MARK:Y?'));
        end
        %% ������
        function out_put=read_Data(obj)
            
            fprintf(obj.fs,'TRAC:DATA? TRACE1');
            str_num=1;
            str_data{str_num}=fscanf(obj.fs,'TRAC:DATA? TRACE1');
            l=length(str_data{str_num});
            while l==512%һ����ȡ��ԪΪ512*char����������Ϊ+/-X.XXXXX0EXX���ã��ָ�
                str_num=str_num+1;
                str_data{str_num}=fscanf(obj.fs,'TRAC:DATA? TRACE1');
                l=length(char(str_data(str_num)));
            end
            out_put=zeros(1,((str_num-1)*512+l)/13);
            
            str=[];
            num=0;
            for i=1:length(str_data)
                str=strcat(str,char(str_data{i}));
                l=length(str);
                zh=fix(l/13);%�������һ�����ݣ������ľ���13Ϊһ����Ԫ
                tt=mod(l,13);
                str_cell=strsplit(str,',');
                for j=1:zh
                    out_put(j+num)=str2num(char(str_cell{j}));
                end
                num=num+zh;
                if (zh*13+1)<=length(str)
                    str=str((zh*13+1):length(str));
                else
                    str=[];
                end
            end
            out_put(num+1)=str2num(char(str_cell{j+1}));
            disp('E4440A Read Complete');
        end
        %% ���ƽ������
        function set_AVER_CLE(obj)
            fprintf(obj.fs,':SENS:AVER:CLE');
            %             fprintf(obj.fs,':SENS:AVER:OFF');
        end
        %% ����ƽ������
        function set_AVER_Num(obj,num)
            fprintf(obj.fs,':SENS:AVER:COUNT %d',num);
            fprintf(obj.fs,':SENS:AVER:ON');
        end
        function out_put=read_Frq_start(obj)
            out_put=query(obj.fs,'FREQ:STARt?');
        end
        function out_put=read_Frq_end(obj)
            out_put=query(obj.fs,'FREQ:STOP?');
        end
        %%
        function delete(obj)
            fclose(obj.fs);
            delete(obj);
        end
    end
end

