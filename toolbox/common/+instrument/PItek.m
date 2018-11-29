classdef PItek< instrument.Protocol
    %% Abstract
    %   PBiasDac£ºitek
    %   transmission protocol: +instrument/Protocol
    %% Index
    %   @read(channel)(volt)
    %   @set(channel,value)(volt)
    %% Comments
    %   channel range: 1~16
    %   set_volt range: -10V ~ +10V
    
    %%
    methods
        %% Connect
        function itek = PItek(address)
            itek = itek@instrument.Protocol(address);
            itek.handle.Terminator=13;
        end
        
        %% @read(channel)(volt)
        function volt = read_volt(itek,channel)
            switch channel
                case{1,2,3,4,5,6,7,8,9,10}
                    order = sprintf('R%d\n',channel-1);
                case {11,12,13,14,15,16}
                    order = sprintf('R%c\n',97+channel-11);
            end
            result = query(itek.handle,order);
            volt = str2double(result);
        end
        
        %% @set(channel,value)(volt)
        function set_volt(itek,channel,valuie)
            switch channel
                case{1,2,3,4,5,6,7,8,9,10}
                    order = sprintf('S%d%g',channel-1,valuie);
                case {11,12,13,14,15,16}
                    order = sprintf('S%c%g',97+channel-11,valuie);
            end
            query(itek.handle,order);
        end
    end
    
end
