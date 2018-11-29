classdef E4440A<handle
    % Agilent 频谱仪
    % 2018.11.23 by lt
    properties
        fs;
    end
    
    methods
        function obj = E4440A(address)
            %构造此类的实例
            obj.fs = instrfind('Type', 'visa-tcpip', 'RsrcName', address, 'Tag', '');
            obj.fs=visa('AGILENT',address);
            %GPIB接入
            fopen(obj.fs);
        end
        %% 设置中心频率
        function set_Center_Frq(obj,frq)
            fprintf(obj.fs,':SENSe:FREQuency:CENTer %d',frq);
        end
        %% 设置频率宽度
        function set_Frq_Span(obj,span)
            fprintf(obj.fs,':SENSe:FREQuency:SPAN %d',span);
        end
        %% 读Y轴数据
        function out_put=read_Y(obj)
            out_put=str2num(query(obj.fs,':CALC:MARK:Y?'));
        end
        %% 读数据
        function out_put=read_Data(obj)
            
            fprintf(obj.fs,'TRAC:DATA? TRACE1');
            str_num=1;
            str_data{str_num}=fscanf(obj.fs,'TRAC:DATA? TRACE1');
            l=length(str_data{str_num});
            while l==512%一个读取单元为512*char，数据类型为+/-X.XXXXX0EXX并用，分隔
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
                zh=fix(l/13);%除了最后一个数据，其他的就是13为一个单元
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
        %% 清除平均设置
        function set_AVER_CLE(obj)
            fprintf(obj.fs,':SENS:AVER:CLE');
            %             fprintf(obj.fs,':SENS:AVER:OFF');
        end
        %% 设置平均次数
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

