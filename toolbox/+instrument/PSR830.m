classdef PSR830 < instrument.Protocol
    %% Abstract
    %   PSR830£ºlockin
    %   transmission protocol: +instrument/Protocol
    
    %%   Index
    %   @read(channel)(current / aux / freq / amp / input_mode / sens)
    %   @set(channel,value)(aux / freq / amp / input_mode / sens)
    
    %% Comments
    %   channel: current: X:1 Y:2 R:3 Theta:4
    %            aux: 1 2 3 4
    %
    %   value: read_input_mode: 0:I 1:V
    
    %%
    methods
        %% Connect
        function lockin = PSR830(address)
            lockin = lockin@instrument.Protocol(address);
        end
        
        %% @read(channel)(current / aux / freq / amp / input_mode / sens)
        function I_read=  read_current(lockin,channel)% X:1 Y:2 R:3 Theta:4
            order = sprintf('OUTP ? %d\n',channel);
            result = lockin.Command1(order);
            I_read = str2double(result);
        end
        
        function V_read = read_aux(lockin,channel)
            order = sprintf('AUXV? %d\n',channel);
            result = lockin.Command1(order);
            V_read = str2double(result);
        end
        
        function freq = read_freq(lockin,~)
            order = sprintf('FREQ?\n');
            result = lockin.Command1(order);
            freq = str2double(result);
        end
        
        function amp = read_amp(lockin,~)
            order = sprintf('SLVL?\n');
            result = lockin.Command1(order);
            amp = str2double(result);
        end
        
        function mode = read_input_mode(lockin,~)
            order = sprintf('ISRC?\n');
            result = lockin.Command1(order);
            r = str2double(result);
            if r == 0 || r == 1
                mode = 1;
            else
                mode = 0;
            end
        end
        
        function sens = read_sens(lockin,~)
            order = sprintf('SENS?\n');
            result = lockin.Command1(order);
            sens = str2double(result);
        end
        
        %% @set(channel,value)(aux / freq / amp / input_mode / sens)
        function set_aux(lockin,channel,value)
            order = sprintf('AUXV %d,%f\n',channel,value);
            lockin.Command2(order);
        end
        
        function set_freq(lockin,~,freq)
            order = sprintf('FREQ %f\n',freq);
            lockin.Command2(order);
        end
        
        function set_amp(lockin,~,amp)
            order = sprintf('SLVL %f\n',amp);
            lockin.Command2(order);
        end
        
        function set_sens(lockin,~,sens)
            order= sprintf('SENS %d\n',sens);
            lockin.Command2(order);
        end
        
        function set_input_mode(lockin,~,mode)
            order = sprintf('ISRC %d',mode);
            lockin.Command2(order);
        end
    end
end
