classdef Protocol < handle
    %% Protocol
    %   连接仪器
    %   open、close、delete
    %   Command1向仪器发送指令并接收返回值
    %   Command2向仪器发送指令且不接收返回值
    %% Comment
    %   address格式为一维元胞，且address{1}固定为连接协议类型：VISA-GPIB、VISA-TCPIP、GPIB、TCPIP
    
    %% 以下为正文
    properties(Access = public)
        handle;
        address;
    end
    
    methods
        %% connect
        function instr = Protocol(address)
            instr.address = address;
            switch address{1}
                case 'VISA-GPIB'%VISA-GPIB协议 & keysight仪器 e.g.{'VISA-GPIB',1,10}
                    add = ['GPIB' num2str(address{2}) '::' num2str(address{3}) '::INSTR'];
                    instr.handle = instrfind('Type', 'visa-gpib', 'RsrcName', add, 'Tag', '');
                    if isempty(instr.handle)
                        instr.handle = instrfind('Type', 'visa-gpib', 'RsrcName', add, 'Tag', '');
                    end
                    if isempty(instr.handle)
                        instr.handle = visa('AGILENT',add);
                    else
                        fclose(instr.handle);
                        instr.handle = instr.handle(1);
                    end
                case 'VISA-TCPIP'%VISA-TCPIP协议 & keysight仪器 e.g.{'VISA-TCPIP','192.168.1.1'}
                    add = ['TCPIP::' address{2} '::INSTR'];
                    instr.handle = instrfind('Type', 'visa-tcpip', 'RsrcName', add, 'Tag', '');
                    if isempty(instr.handle)
                        instr.handle = instrfind('Type', 'visa-tcpip', 'RsrcName', add, 'Tag', '');
                    end
                    if isempty(instr.handle)
                        instr.handle = visa('AGILENT', add);
                    else
                        fclose(instr.handle);
                        instr.handle = instr.handle(1);
                    end
                case 'GPIB'%GPIB协议 & keysight仪器 e.g.{'GPIB',7,10}
                    instr.handle = instrfind('Type', 'gpib', 'BoardIndex', address{2}, 'PrimaryAddress', address{3}, 'Tag', '');
                    if isempty(instr.handle)
                        instr.handle = gpib('AGILENT',address{2}, address{3});
                    else
                        fclose(instr.handle);
                        instr.handle = instr.handle(1);
                    end
                case 'TCPIP'%TCPIP协议 e.g.{'TCPIP','192.168.1.1',80}
                    instr.handle = instrfind('Type', 'tcpip', 'RemoteHost', address{2}, 'RemotePort', address{3}, 'Tag', '');
                    if isempty(instr.handle)
                        instr.handle = tcpip(address{2},address{3});
                    else
                        fclose(instr.handle);
                        instr.handle = instr.handle(1);
                    end
            end
        end
        
        %% open / close / delete        
        function open(instr)
            if strcmp(instr.handle.status,'closed')
                fopen(instr.handle);
            end
        end
        
        function close(instr)
            if strcmp(instr.handle.status,'open')
                fclose(instr.handle);
            end
        end
        
        function delete(instr)
            instr.close();
            delete(instr.handle);
        end
        
        %% Command1 / Command2
        function result = Command1(instr,order)%需要fscanf读取handle内容时使用
            if strcmp(instr.handle.status,'closed')
                isopened = 0;
                fopen(instr.handle);
            else
                isopened = 1;
            end
            success_flag = 0;
            t = 0;
            while ~success_flag
                try
                    success_flag = 1;
                    fprintf(instr.handle,order);
                catch exception
                    if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                        success_flag = 0;
                        t = t + 1;
                        if t < 10
                            disp([datestr(now), ' : ', exception.message]);
                            pause(2);
                        else
                            error([datestr(now), ' : ', exception.message]);
                        end
                    else
                        rethrow(exception);
                    end
                end
            end
            result = fscanf(instr.handle);
            if ~isopened
                fclose(instr.handle);
            end
        end
        
        
        function Command2(instr,order)%不需要fscanf读取handle内容时使用
            if strcmp(instr.handle.status, 'closed')
                isopened = 0;
                fopen(instr.handle);
            else
                isopened = 1;
            end
            success_flag = 0;
            t = 0;
            while ~success_flag
                try
                    success_flag = 1;
                    fprintf(instr.handle,order);
                catch exception
                    if strcmp(exception.identifier, 'instrument:fprintf:opfailed')
                        success_flag = 0;
                        t = t + 1;
                        if t < 10
                            disp([datestr(now), ' : ', exception.message]);
                            pause(2);
                        else
                            error([datestr(now), ' : ', exception.message]);
                        end
                    else
                        rethrow(exception);
                    end
                end
            end
            if ~isopened
                fclose(instr.handle);
            end
        end
    end
end

