function ips_set_field(app,instr,channel,value)
instr.open();
instr.set_hold(channel,1);
state = instr.read_heat(channel);
if ~state
    internal_field = instr.read_persistent_field(channel);    
    start = instr.read_field(channel);
    if abs(internal_field - start) > 1
        instr.set_target_field(channel,internal_field);
        instr.to_set(channel);
        tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on,',channel+87,internal_field,start);%显示等待进度条
        hwait = uiprogressdlg(app.UIFigure,'Title','Setting Field','Message',tips);
        pause(1);
        f = start;
        while(abs(f - internal_field) >= 0.1)
            f=instr.read_field(channel);
            hwait.Value = 1-abs(f-value)/abs(start-value);
            hwait.Message = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now',channel+87,internal_field,f);%更新进度条
            pause(1);
        end
        hwait.Message = 'Now turning heater ON';
        close(hwait);
    end
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
    hwait = uiprogressdlg(app.UIFigure,'Title','Setting Field','Message',tips);
    pause(1);
    f = start;
    while(abs(f - value) >= 0.1)
        f = instr.read_field(channel);
        hwait.Value = 1-abs(f-value)/abs(start-value);
        hwait.Message = sprintf('Setting %c Field to %g mT,%g mT now',channel+87,value,f);%更新进度条
        pause(1);
    end
    delete(hwait);
end
instr.set_hold(channel,1);
instr.close();
end

