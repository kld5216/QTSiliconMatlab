classdef PKeithley2015 < instrument.Protocol
    %% Abstract
    %   PKeithley2015£ºdmm
    %   transmission protocol: +instrument/Protocol
    %% Index
    %   @read_current
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
        function value = read_current(dmm,~)
            order = sprintf('fetch?');
            result = query(dmm.handle,order);
            value=str2double(result);
        end
        
        %% @set(~,channel)(channel)
        function set_channel(dmm,channel)
            order = sprintf('rout:term fron%d',channel);
            fprintf(dmm.handle,order);
        end
    end
    
end

