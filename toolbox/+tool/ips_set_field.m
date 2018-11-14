function ips_set_field(instr,channel,value)
instr.open();
instr.set_hold(channel,1);
state = instr.read_heat(channel);
if ~state
    internal_field = instr.read_persistent_field(channel);
    instr.set_target_field(channel,internal_field);
    instr.to_set(channel);
    f=instr.read_field(channel);
    tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on,',channel+87,internal_field,f);%显示等待进度条
    hwait = waitbar(f/internal_field,tips,'Name','Setting Field');
    pause(1);
    while(abs(f - internal_field) >= 0.1)
        f=instr.read_field(channel);
        tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on.',channel+87,internal_field,f);%更新进度条
        waitbar(f/internal_field,hwait,tips);
        pause(1);
    end
    delete(hwait);
    instr.set_hold(channel,1);
    instr.set_heat(channel,1);
elseif state == -1
    error('heater state error,please check!');
end
start = instr.read_field(channel);
instr.set_target_field(channel,value);
instr.to_set(channel);
if abs(start - value) >= 0.1
    tips = sprintf('Setting %c Field to %g mT, %g mT now',channel+87,value,start);%显示等待进度条
    hwait = waitbar(0,tips,'Name','Setting Field');
    pause(1);
    f = start;
    while(abs(f - value) >= 0.1)
        f = instr.read_field(channel);
        tips = sprintf('Setting %c Field to %g mT,%g mT now',channel+87,value,f);%更新进度条
        waitbar(1-abs((f-value))/abs((start-value)),hwait,tips);
        pause(1);
    end
    delete(hwait);
end
instr.set_hold(channel,1);
instr.close();
end

