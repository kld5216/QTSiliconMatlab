function T1Pulse(t_empty,t_charge,t_read,Vpp1,Vpp2,V_amp)
%% awg参数设定
%   Vpp1:pulse1相对振幅
%   Vpp2: pulse2相对振幅
%   V_amp:pulse总振幅  注意：实际Vpp为设定的两倍
%   t_empty: 初始化时间
%   t_charge: charge时间
%   t_read : read时间   

name = 'T1test';%波形文件名称
IP = '192.168.1.115';%a33522a IP地址
sRate = 100e3;%awg33522a采样率

%% 生成波形
point{1} = [0, 0];
point{2} = [t_empty/1000, Vpp1];
point{3} = [(t_empty + t_charge)/1000, Vpp2];
point{4} = [(t_empty + t_charge + t_read)/1000, 0];

totalpoints = sRate * (t_empty + t_charge + t_read) / 1000;
arb = zeros(1,totalpoints);
%     file = CFile(sprintf('E:\\people\\HRZ\\data\\T1\\test1\\%d\\',i));
for j = 1:3
    for i = sRate * point{j}(1) + 1:sRate * point{j+1}(1)
        arb(i) = point{j}(2);
    end
end

tool.arbTo33500(arb,IP,V_amp,sRate,name);
pause(1);
end