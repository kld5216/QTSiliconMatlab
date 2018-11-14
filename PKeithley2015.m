classdef PKeithley2015 < instrument.Protocol
    %% Abstract
    %   PKeithley2015£ºdmm
    %   transmission protocol: +instrument/Protocol
    %% Index
    %   @read
    %   @set(~,channel)(channel)
    %% Comments
    %   channel range: 1~2
    
    methods
        %% Connect
        function dmm = PKeithley2015(address)
            dmm = dmm@instrument.Protocol(address);
            dmm.handle.EosCharCode='LF';
            dmm.handle.EosMode='read&write';
        end

        %% @read
        function value = read(dmm,~)
            order = sprintf('Read?\n');
            result = dmm.Command1(order);
            value=str2double(result);
        end
        
        %% @set(~,channel)(channel)
        function set_channel(dmm,~,channel)
            order = sprintf('rout:term fron%d\n',channel);
            dmm.Command2(order);
        end
    end
    
end

