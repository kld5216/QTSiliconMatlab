function T1Pulse(t_empty,t_charge,t_read,Vpp1,Vpp2,V_amp)
%% awg�����趨
%   Vpp1:pulse1������
%   Vpp2: pulse2������
%   V_amp:pulse�����  ע�⣺ʵ��VppΪ�趨������
%   t_empty: ��ʼ��ʱ��
%   t_charge: chargeʱ��
%   t_read : readʱ��   

name = 'T1test';%�����ļ�����
IP = '192.168.1.115';%a33522a IP��ַ
sRate = 100e3;%awg33522a������

%% ���ɲ���
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