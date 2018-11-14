classdef Pa33522a < instrument.Protocol
    %% Abstract
    %   Pa33522a: agilent33500 series
    %   transmission protocol: +instrument/Protocol
    %% Index
    %   open/close/delete
    %   @read(channel)(freq / amp / period)
    %   @set(channel,value)(freq / amp / period)
    %% Comments
    %   unit for freq / amp / period : Hz / V / s
    %   for arb , use func 'tool.arbTo33500'
    
    methods
        %% Connect
        function a33522a = Pa33522a(address)
            a33522a = a33522a@instrument.Protocol(address);
        end
        
        %% open/close/delete
        function open(instr)
            if instr.isopened
                return;
            end
            fopen(instr.handle);
            instr.isopened=1;
            
        end
        function close(instr)
            if instr.isopened
                fclose(instr.handle);
                instr.isopened=0;
            end
        end
        function delete(instr)
            if instr.isopened
                instr.close();
            end
            delete(instr.handle);
        end
        
        %% @read(channel)(freq / amp / period)
        function freq = read_freq(a33522a,channel)
            order = sprintf(':sour%d:freq?\n',channel);
            result = a33522a.Command1(order);
            freq = str2double(result);
        end
        
        function amp = read_amp(a33522a,channel)
            order = sprintf(':sour%d:volt?\n',channel);
            result = a33522a.Command1(order);
            amp = str2double(result);
        end
        
        function period = read_period(a33522a,channel)
            order = sprintf(':sour%d:func:squ:per?\n',channel);
            result = a33522a.Command1(order);
            period = str2double(result);
        end
        
        %% @set(channel,value)(freq / amp / period)
        function set_freq(a33522a,channel,value)%units Hz
            order = sprintf(':sour%d:freq %f\n',channel,value);
            a33522a.Command2(order);
        end
        
        function set_amp(a33522a,channel,value)%units V
            order = sprintf(':sour%d:volt %f\n',channel,value);
            a33522a.Command2(order);
        end
        
        function set_period(a33522a,channel,value)%units s
            order = sprintf(':sour%d:func:squ:per %f\n',channel,value);
            a33522a.Command2(order);
        end
    end
    
end
