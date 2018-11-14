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
% RepeatNum=10;%�����ظ���������


%% awg�����趨
%   ע�⣺ʵ��VppΪ�趨������
name = 'T1test';%�����ļ�����
IP = '192.168.1.115';%a33522a IP��ַ
sRate = 100e3;%awg33522a������
% file_out = CFile('E:\people\HRZ\data\T1\test\');%����ļ���

Vpp1 = 1;%pulse1������
Vpp2 = 0.5; %pulse2������
V_amp = 0.04;%pulse�����
t_empty = 10;%��ʼ��ʱ��
t_charge = 10;%chargeʱ��
t_read = 10;%readʱ��


%% �ɼ���
% inst_Digitizer = CATS_nm(1);%systemID AlazarDSO�Ͽ����ҵ�������1����2
% inst_Digitizer.setSampleRate(SampleRate);%�����ʣ�Ҫ��AlazarDSO�����õ�һ��
% inst_Digitizer.setSampleCount(SampleCount);%�ɼ�����
% inst_Digitizer.setRepeatCount(RepeatCount);%�ظ��ɼ�����
% data = inst_Digitizer.acquire(1);

% inst_Digitizer2 = CATS(2);%systemID AlazarDSO�Ͽ����ҵ�������1����2
% inst_Digitizer2.setSampleRate(SampleRate);%�����ʣ�Ҫ��AlazarDSO�����õ�һ��
% inst_Digitizer2.setSampleCount(SampleCount);%�ɼ�����
% inst_Digitizer2.setRepeatCount(ReaptCount);%�ظ��ɼ�����

% AUX_FLUX = 1;%channel1

% %% ���ݴ洢
% file = CFile('E:\people\HRZ\data\T1\test\');
% path=file.folder.getCurrentPath();

%% ��������Ҫɨ�Ĳ���

point{1} = [0, 0];
point{2} = [t_empty/1000, Vpp1];
point{3} = [(t_empty + t_charge)/1000, Vpp2];
point{4} = [(t_empty + t_charge + t_read)/1000, 0];

totalpoints = sRate * (t_empty + t_charge + t_read) / 1000;
arb = zeros(1,totalpoints);

threshold = 0;%read out ��ֵ����
%% ʵ�����ݱ�
% y_list = (y_step:y_step:y_end)'; 
% N=length(y_list);
% amp_list = zeros(N,1);
% phase_list = zeros(N,1);
% Total_Length=Total_Time_us * 1e3 * SamplesPerMicrosecond;
% ini_value=zeros(Total_Length,1);

%% ��������
% fid = fopen([file_out.path,'\test.dat'],'w');%����ļ���

for t_empty = 10:15    %ɨ�����/from/step/to
    %     file = CFile('E:\people\HRZ\data\T1\test\');
    % path=file.folder.getCurrentPath();
    
    
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
    
    arbTo33500(arb,IP,V_amp,sRate,name);
    pause(1);
    %%
    
    count = 0;% readout����
%     data = inst_Digitizer.acquire(VoltageAmplitude);
%     for j = 1 : RepeatCount
%         file.save([time' data.CHA(j,:)']);%��������
%         for k = 1 : SampleCount
%             if data.CHA(j,k) > threshold
%                 count = count + 1;%�Ƚ���ֵ�����������+1��������ѭ��
%                 break;
%             end
%         end
%     end
%     fprintf(fid,'%f\t%f\r\n',i*TimeSpace-TimeSpace,count/RepeatCount);%������������
end
% fclose(fid);
% file.close();
%% ���ݴ洢
% file_out.save([t' prob']);%��������
% figure;%��ͼ
% subplot(2,1,1);
% plot(t,prob);
% clear temp t prob count;
% file.save([time' dat]);
% plot(y_list,amp_list);
% fName1=sprintf('Rabi-Amp\nProbePower=%.2fdBm ProbeFreq=%.4fGHz\nDrivePower=%.2fdBm Vpp=%.2fV DriveFreq=%.4fGHz',Pp,Pf/1e9,Dp,Vpp,Df/1e9);
% title(fName1);
% xlabel('pulse time');
% ylabel('Amp');
% print(gcf,'-dbitmap',[path,'Rabi-Amp','.bmp']);
% saveas(gcf,[path,'Rabi-Amp','.fig']);

