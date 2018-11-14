classdef PIPS < instrument.Protocol%�ų��ĵ�λ��mT
    %% Abstract
    %   PIPS��IPS @triton3, magnet @ X/Z direction in use, HAVE heater mode
    %   transmission protocol: +instrument/Protocol
    
    %% Index
    %   @(channel)(to_set / to zero)
    %   @read(channel)(hold / heat /target_field / ramp_rate / field / persistent_field) 
    %   @set(channel,value)(hold / heat / target_field / ramp_rate / field)
    
    %% Comments
    %   'channel + 87' represents 'X'/'Y'/'Z' for channel = 1/2/3 in ASCII
    %   it need 300 seconds to turn heater on/off
    %   magnet unit is always mT
    %   rate unit is always mT/min
    
    %%
    properties(Constant=true)
        waitime = 300;%timw waiting for heat on/off
    end
    methods
       %% Connect
        function ips = PIPS(address)
            ips = ips@instrument.Protocol(address);
        end        

        %% @(channel)(to_set / to zero)
        
        function state = to_set(ips,channel)
            order = sprintf('SET:DEV:GRP%c:PSU:ACTN:RTOS\n',channel+87);
            result = ips.Command1(order);
            if strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:ACTN:RTOS:VALID\n',channel+87))
                state = 1;
            else
                state = 0;
            end
        end
        
         function state = to_zero(ips,channel)
             order = sprintf('SET:DEV:GRP%c:PSU:ACTN:RTOZ\n',channel+87);
             result = ips.Command1(order);
            if strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:ACTN:RTOZ:VALID\n',channel+87))
                state = 1;
            else
                state = 0;
            end
         end

         %% @read(channel)(hold / heat /target_field / ramp_rate / field / persistent_field)
         function state = read_hold(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:ACTN\n',channel+87);
            result = ips.Command1(order);
            if ~strcmp(result,sprintf('STAT:DEV:GRP%c:PSU:ACTN:HOLD\n',channel+87))
                state = 0;
                return;
            end
            state = 1;            
         end
         
         function state = read_heat(ips,channel)
             order = sprintf('READ:DEV:GRP%c:PSU:SIG:SWHT',channel+87);
             result = ips.Command1(order);             
             if strcmp(result,sprintf('STAT:DEV:GRP%c:PSU:SIG:SWHT:OFF\n',channel+87))
                 state = 0;
             elseif strcmp(result,sprintf('STAT:DEV:GRP%c:PSU:SIG:SWHT:ON\n',channel+87))
                 state = 1;
             else
                 state = -1;
             end
         end
        
         function targetF = read_target_field(ips,channel)             
             order = sprintf('READ:DEV:GRP%c:PSU:SIG:FSET\n',channel+87);
             result = ips.Command1(order);
             targetF = str2double(result(28:33));
             if isnan(targetF)
                 ips.close();
                 errordlg('read target field error');
                 return;
             end
             targetF = targetF * 1000;
         end
         
         function rate = read_ramp_rate(ips,channel)
             order = sprintf('READ:DEV:GRP%c:PSU:SIG:RFST',channel+87);
             result = ips.Command1(order);
             rate = str2double(result(28:33));
             t = 1;
             while isnan(rate)
                 if t > ips.max_try
                     ips.close;
                     error('read ramp rate error');
                 end
                 t = t + 1;
                 result = ips.Command1(order);
                 rate = str2double(result(28:33));
             end
             rate = rate * 1000;
         end
         
         function field = read_field(ips,channel)
             order = sprintf('READ:DEV:GRP%c:PSU:SIG:FLD',channel+87);
             result = ips.Command1(order);
             field = str2double(result(27:32));
             t = 1;             
             while isnan(field)
                 if t > ips.max_try
                     ips.close;
                     error('read field error');
                 end
                 t = t + 1;
                 result = ips.Command1(order);
                 field = str2double(result(27:32));
             end
             field = field * 1000;
         end
        
         function field = read_persistent_field(ips,channel)
            order = sprintf('READ:DEV:GRP%c:PSU:SIG:PFLD',channel+87);
            result = ips.Command1(order);
            field = str2double(result(28:33));           
            t = 1;            
            while isnan(field)
                if t > ips.max_try
                    ips.close;
                    error('read internal field error');
                end
                t = t + 1;
                result = ips.Command1(order);
                field = str2double(result(28:33));
            end
            field = field * 1000;
         end
        
         %% @set(channel,value)(hold / heat / target_field / ramp_rate / field)
         
         function state = set_hold(ips,channel,value)
             if value
                 key = 'HOLD';
             else
                 key = 'CLMP';
             end             
             order = sprintf('SET:DEV:GRP%c:PSU:ACTN:%s\n',channel+87,key);
             result = ips.Command1(order);
             if strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:ACTN:%s:VALID\n',channel+87,key))
                 state = 1;
             else
                 state = 0;
             end
         end
         
         function state = set_heat(ips,channel,value)
             if value
                 key = 'ON';
             else
                 key = 'OFF';
             end
             order = sprintf('SET:DEV:GRP%c:PSU:SIG:SWHT:%s\n',channel+87,key);
             result = ips.Command1(order);
             if strcmp(result,sprintf('STAT:SET:DEV:GRP%c:PSU:SIG:SWHT:%s:VALID\n',channel+87,key))
                 tips = sprintf('heater %s ...Please wait %d seconds',key,ips.waitime);%��ʾ�ȴ�������
                 hwait = waitbar(0,tips,'Name',sprintf('Turning Heater %s',key));
                 pause(1);
                 for i = 1:ips.waitime-1
                     tips = sprintf('%d seconds remaining',ips.waitime-i);
                     waitbar(i/ips.waitime,hwait,tips);
                     pause(1);
                 end
                 delete(hwait);
                 state = 1;
             else
                 state = 0;
                 errordlg(sprintf('heater %s FAILED, please retry!',key));
                 return;
             end
             
         end
         
         function set_target_field(ips,channel,value)
            rvalue = value/1000;
            order = sprintf('SET:DEV:GRP%c:PSU:SIG:FSET:%.4f\n',channel+87,rvalue);
            t = 1;
            while abs(ips.read_target_field(channel) - value) >= 0.1
                if t > ips.max_try
                    ips.close;
                    error('set target field error');
                end
                ips.Command1(order);
                t = t + 1;
            end
          end
          
          function set_ramp_rate(ips,channel,value)
              rrate = value/1000;
              order = sprintf('SET:DEV:GRP%c:PSU:SIG:RFST:%.4f',channel+87,rrate);
              t = 1;
              while abs(ips.read_ramp_rate(channel)-value) >= 0.1
                  if t > ips.max_try
                      ips.close;
                      error('set ramp rate error');
                  end
                  ips.Command1(order);
                  t = t + 1;
              end
          end
          
          function set_field(ips,channel,value)
              ips.open();
              ips.set_hold(channel,1);
              state = ips.read_heat(channel);
              if ~state
                  internal_field = ips.read_persistent_field(channel);
                  ips.set_target_field(channel,internal_field);
                  ips.to_set(channel);
                  f=ips.read_field(channel);
                  tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on,',channel+87,internal_field,f);%��ʾ�ȴ�������
                  hwait = waitbar(f/internal_field,tips,'Name','Setting Field');
                  pause(1);
                  while(abs(f - internal_field) >= 0.1)
                      f=ips.read_field(channel);
                      tips = sprintf('Setting %c External Field to Persistent Field, %g mT of %g mT now, then turning heater on.',channel+87,internal_field,f);%���½�����
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
                  tips = sprintf('Setting %c Field to %g mT, %g mT now',channel+87,value,start);%��ʾ�ȴ�������
                  hwait = waitbar(0,tips,'Name','Setting Field');
                  pause(1);
                  f = start;
                  while(abs(f - value) >= 0.1)
                      f = ips.read_field(channel);
                      tips = sprintf('Setting %c Field to %g mT,%g mT now',channel+87,value,f);%���½�����
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