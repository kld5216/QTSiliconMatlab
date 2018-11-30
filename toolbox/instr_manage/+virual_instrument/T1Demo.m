%% header
clear;
import instrument.*;
import tool.*;


%% 采集卡参数设定
SampleRate=100e3;%采样率，要和AlazarDSO上设置的一致
SampleCount=1024;%采集点数
RepeatCount=1000;%重复采集次数++++++++++++++++++
VoltageAmplitude=2;%设置纵向电压幅值
time=1/SampleRate:1/SampleRate:(SampleCount/SampleRate);%对应于采集点的时间

%% awg参数设定
%   注意：实际Vpp为设定的两倍
Vpp1 = 1;%pulse1相对振幅
Vpp2 = 0.5; %pulse2相对振幅
V_amp = 0.04;%pulse总振幅
t_empty = 10;%初始化时间
t_charge = 10;%charge时间
t_read = 10;%read时间

%% 采集卡
inst_Digitizer = CATS_nm(1);%systemID AlazarDSO上可以找到，不是1就是2
inst_Digitizer.setSampleRate(SampleRate);%采样率，要和AlazarDSO上设置的一致
inst_Digitizer.setSampleCount(SampleCount);%采集点数
inst_Digitizer.setRepeatCount(RepeatCount);%重复采集次数

% inst_Digitizer2 = CATS(2);%systemID AlazarDSO上可以找到，不是1就是2
% inst_Digitizer2.setSampleRate(SampleRate);%采样率，要和AlazarDSO上设置的一致
% inst_Digitizer2.setSampleCount(SampleCount);%采集点数
% inst_Digitizer2.setRepeatCount(ReaptCount);%重复采集次数

%% 测量过程
for t_empty = 10:15    %扫描参数/from/step/to    
    %% 生成波形
    T1Pulse(t_empty,t_charge,t_read,Vpp1,Vpp2,V_amp);
    %% 采集卡计数
    data = inst_Digitizer.acquire(VoltageAmplitude);
    file = CFile('E:\people\HRZ\data\T1\test\');
    for j = 1 : RepeatCount
        file.save([time' data.CHA(j,:)']);%导出数据
    end
    delete(file);
end