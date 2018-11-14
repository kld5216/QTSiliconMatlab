classdef PBiasDac< instrument.Protocol
    %% Abstract
    %   PBiasDac£ºitek
    %   transmission protocol: +instrument/Protocol
    %% Index
    %   open/close/delete
    %   @read(channel)(volt)
    %   @set(channel,value)(volt)
    %% Comments
    %   channel range: 1~16
    %   set_volt range: -10V ~ +10V
    
    %%
    methods
        %% Connect
        function itek = PBiasDac(address)
            itek = itek@instrument.Protocol(address);
            itek.handle.Terminator=13;
        end
        
        %% open/close/delete
        function open(itek)
            if itek.isopened
                return;
            end
            fopen(itek.handle);
            itek.isopened=1;
            
        end
        function close(itek)
            if itek.isopened
                fclose(itek.handle);
                itek.isopened=0;
            end
        end
        function delete(itek)
            if itek.isopened
                itek.close();
            end
            delete(itek.handle);
        end
        
        %% @read(channel)(volt)
        function volt = read_volt(itek,channel)
            switch channel
                case{1,2,3,4,5,6,7,8,9,10}
                    order = sprintf('R%d\n',channel-1);
                case {11,12,13,14,15,16}
                    order = sprintf('R%c\n',97+channel-11);
                otherwise
                    error('wrong channel');
            end
            result = itek.Command1(order);
            volt = str2double(result);
        end
        
        %% @set(channel,value)(volt)
        function set_volt(itek,channel,valuie)
            switch channel
                case{1,2,3,4,5,6,7,8,9,10}
                    order = sprintf('S%d%g',channel-1,valuie);
                case {11,12,13,14,15,16}
                    order = sprintf('S%c%g',97+channel-11,valuie);
                otherwise
                    error('wrong channel');
            end
            itek.Command1(order);
        end
    end
    
end
