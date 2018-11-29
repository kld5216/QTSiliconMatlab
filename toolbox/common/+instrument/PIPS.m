classdef PIPS < instrument.Protocol%磁场的单位是mT
    %% Abstract
    %   PIPS：IPS @triton3, magnet @ X/Z direction in use, HAVE heater mode
    %   transmission protocol: +instrument/Protocol
    
    %% Index
    %   @read(channel)(action / heat /target_field / ramp_rate / field / persistent_field)
    %   @set(channel,value)(action / heat / target_field / ramp_rate)
    
    %% Comments
    %   'channel + 87' represents 'X'/'Y'/'Z' for channel = 1/2/3 in ASCII
    %   it need 300 seconds to turn heater on/off
    %   magnet unit is always T
    %   rate unit is always T/min
    
    %%
    properties(Constant=true)
        waitime = 300;%timw waiting for heat on/off
    end
    methods
        %% Connect
        function ips = PIPS(address)
            ips = ips@instrument.Protocol(address);
        end
       
        %% @read(channel)(action / heatState /target_field / ramp_rate / field / persistent_field)
        function state = read_action(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:ACTN\n',channel+87);
            result = query(ips,order);
            switch result(24:27)
                case 'CLMP'
                    state = 0;
                case 'HOLD'
                    state = 1;                
                case 'ROTZ'
                    state = 2;
                case 'ROTS'
                    state = 3;
                otherwise
                    error('PIPS:incorrectResponse','read State error');
            end
        end
        
        function state = read_heatState(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:SWHT',channel+87);
            result = query(ips,order);
            if strcmp(result(28:30),'OFF')
                state = 0;
            elseif strcmp(result(28:29),'ON')
                state = 1;
            else
                state = -1;
            end
        end
        
        function targetF = read_target_field(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:FSET\n',channel+87);
            result = query(ips,order);
            targetF = str2double(regexp(result, '-?\d*\.?\d*', 'match'));
            if isnan(targetF)
                error('PIPS:incorrectResponse','read target field error');
            end
        end
        
        function rate = read_ramp_rate(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:RFST',channel+87);
            result = query(ips,order);
            rate = str2double(regexp(result, '-?\d*\.?\d*', 'match'));
            if isnan(rate)
                error('PIPS:incorrectResponse','read target field error');
            end
        end
        
        function field = read_field(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:FLD',channel+87);
            result = query(ips,order);
            field = str2double(regexp(result, '-?\d*\.?\d*', 'match'));
            if isnan(field)
                error('PIPS:incorrectResponse','read field error');
            end
        end
        
        function field = read_persistent_field(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:PFLD',channel+87);
            result = query(ips,order);
            field = str2double(regexp(result, '-?\d*\.?\d*', 'match'));
            if isnan(field)
                error('PIPS:incorrectResponse','read internal field error');
            end
        end
        
        %% @set(channel,value)(action / heat / target_field / ramp_rate)
        
        function set_action(ips,channel,value)
            switch value
                case 0
                    key = 'CLMP';
                case 1
                    key = 'HOLD';
                case 2
                    key = 'ROTZ';
                case 3
                    key = 'ROTS';
            end
            order = sprintf('SET:DEV:GRP%c:PSU:ACTN:%s\n',channel+87,key);
            result = query(ips,order);
            if ~strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:ACTN:%s:VALID\n',channel+87,key))
                error('PIPS:incorrectResponse','set %s state error',key);
            end
        end
        
        function set_heat(ips,channel,value)
            if value
                key = 'ON';
            else
                key = 'OFF';
            end
            order = sprintf('SET:DEV:GRP%c:PSU:SIG:SWHT:%s\n',channel+87,key);
            result = query(ips,order);
            if ~strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:SIG:SWHT:%s:VALID\n',channel+87,key))
                error('PIPS:incorrectResponse','set heat %s state error',key);
            end
        end
        
        function set_target_field(ips,channel,value)
            order = sprintf('SET:DEV:GRP%c:PSU:SIG:FSET:%.4f\n',channel+87,value);
            query(ips,order);
            if abs(ips.read_target_field(channel) - value) >= 0.001
                error('PIPS:incorrectResponse','set target field error');
            end
        end
        
        function set_ramp_rate(ips,channel,value)
            order = sprintf('SET:DEV:GRP%c:PSU:SIG:RFST:%.4f',channel+87,value);
            query(ips,order);
            if abs(ips.read_ramp_rate(channel)-value) >= 0.001
                error('PIPS:incorrectResponse','set ramp rate error');
            end
        end
        %% virtual gate
        function set_field(ips,channel,value)
            ips.open();
            ips.set_hold(channel,1);
            state = ips.read_heat(channel);
            if ~state
                internal_field = ips.read_persistent_field(channel);
                ips.set_target_field(channel,internal_field);
                ips.to_set(channel);
                f=ips.read_field(channel);
                tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on,',channel+87,internal_field,f);%显示等待进度条
                hwait = waitbar(f/internal_field,tips,'Name','Setting Field');
                pause(1);
                while(abs(f - internal_field) >= 0.1)
                    f=ips.read_field(channel);
                    tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on.',channel+87,internal_field,f);%更新进度条
                    waitbar(f/internal_field,hwait,tips);
                    pause(1);
                end
                delete(hwait);
                ips.set_hold(channel,1);
                ips.set_heat(channel,1);
            elseif state == -1
                error('heater state error,please check!');
            end
            start = ips.read_field(channel);
            ips.set_target_field(channel,value);
            ips.to_set(channel);
            if abs(start - value) >= 0.1
                tips = sprintf('Setting %c Field to %g mT, %g mT now',channel+87,value,start);%显示等待进度条
                hwait = waitbar(0,tips,'Name','Setting Field');
                pause(1);
                f = start;
                while(abs(f - value) >= 0.1)
                    f = ips.read_field(channel);
                    tips = sprintf('Setting %c Field to %g mT,%g mT now',channel+87,value,f);%更新进度条
                    waitbar(1-abs((f-value))/abs((start-value)),hwait,tips);
                    pause(1);
                end
                delete(hwait);
            end
            ips.set_hold(channel,1);
            ips.close();
        end
    end
end