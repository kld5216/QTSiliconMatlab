function init_channel(instr,idx,value,step,delay)
setter = instr.operate('set',idx);
if strcmp(instr.operate_type,'set')
    setter(value);
    return;
end
reader = instr.operate('read',idx);
current_value = reader();
abs_step=abs(step);
if current_value>value
    while current_value-value>abs_step
        current_value=current_value-abs_step;
        setter(current_value);
        pause(delay);
    end
else
    while value-current_value>abs_step
        current_value=current_value+abs_step;
        setter(current_value);
        pause(delay);
    end
end
setter(value);
pause(delay);
end