%% header
clear;
import instrument.*;
import tool.*;


%% �ɼ��������趨
SampleRate=100e3;%�����ʣ�Ҫ��AlazarDSO�����õ�һ��
SampleCount=1024;%�ɼ�����
RepeatCount=1000;%�ظ��ɼ�����++++++++++++++++++
VoltageAmplitude=2;%���������ѹ��ֵ
time=1/SampleRate:1/SampleRate:(SampleCount/SampleRate);%��Ӧ�ڲɼ����ʱ��

%% awg�����趨
%   ע�⣺ʵ��VppΪ�趨������
Vpp1 = 1;%pulse1������
Vpp2 = 0.5; %pulse2������
V_amp = 0.04;%pulse�����
t_empty = 10;%��ʼ��ʱ��
t_charge = 10;%chargeʱ��
t_read = 10;%readʱ��

%% �ɼ���
inst_Digitizer = CATS_nm(1);%systemID AlazarDSO�Ͽ����ҵ�������1����2
inst_Digitizer.setSampleRate(SampleRate);%�����ʣ�Ҫ��AlazarDSO�����õ�һ��
inst_Digitizer.setSampleCount(SampleCount);%�ɼ�����
inst_Digitizer.setRepeatCount(RepeatCount);%�ظ��ɼ�����

% inst_Digitizer2 = CATS(2);%systemID AlazarDSO�Ͽ����ҵ�������1����2
% inst_Digitizer2.setSampleRate(SampleRate);%�����ʣ�Ҫ��AlazarDSO�����õ�һ��
% inst_Digitizer2.setSampleCount(SampleCount);%�ɼ�����
% inst_Digitizer2.setRepeatCount(ReaptCount);%�ظ��ɼ�����

%% ��������
for t_empty = 10:15    %ɨ�����/from/step/to    
    %% ���ɲ���
    T1Pulse(t_empty,t_charge,t_read,Vpp1,Vpp2,V_amp);
    %% �ɼ�������
    data = inst_Digitizer.acquire(VoltageAmplitude);
    file = CFile('E:\people\HRZ\data\T1\test\');
    for j = 1 : RepeatCount
        file.save([time' data.CHA(j,:)']);%��������
    end
    delete(file);
end