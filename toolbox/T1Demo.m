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
% RepeatNum=10;%单点重复测量次数


%% awg参数设定
%   注意：实际Vpp为设定的两倍
name = 'T1test';%波形文件名称
IP = '192.168.1.115';%a33522a IP地址
sRate = 100e3;%awg33522a采样率
% file_out = CFile('E:\people\HRZ\data\T1\test\');%输出文件夹

Vpp1 = 1;%pulse1相对振幅
Vpp2 = 0.5; %pulse2相对振幅
V_amp = 0.04;%pulse总振幅
t_empty = 10;%初始化时间
t_charge = 10;%charge时间
t_read = 10;%read时间


%% 采集卡
% inst_Digitizer = CATS_nm(1);%systemID AlazarDSO上可以找到，不是1就是2
% inst_Digitizer.setSampleRate(SampleRate);%采样率，要和AlazarDSO上设置的一致
% inst_Digitizer.setSampleCount(SampleCount);%采集点数
% inst_Digitizer.setRepeatCount(RepeatCount);%重复采集次数
% data = inst_Digitizer.acquire(1);

% inst_Digitizer2 = CATS(2);%systemID AlazarDSO上可以找到，不是1就是2
% inst_Digitizer2.setSampleRate(SampleRate);%采样率，要和AlazarDSO上设置的一致
% inst_Digitizer2.setSampleCount(SampleCount);%采集点数
% inst_Digitizer2.setRepeatCount(ReaptCount);%重复采集次数

% AUX_FLUX = 1;%channel1

% %% 数据存储
% file = CFile('E:\people\HRZ\data\T1\test\');
% path=file.folder.getCurrentPath();

%% 测量过程要扫的参数

point{1} = [0, 0];
point{2} = [t_empty/1000, Vpp1];
point{3} = [(t_empty + t_charge)/1000, Vpp2];
point{4} = [(t_empty + t_charge + t_read)/1000, 0];

totalpoints = sRate * (t_empty + t_charge + t_read) / 1000;
arb = zeros(1,totalpoints);

threshold = 0;%read out 阈值条件
%% 实验数据表
% y_list = (y_step:y_step:y_end)'; 
% N=length(y_list);
% amp_list = zeros(N,1);
% phase_list = zeros(N,1);
% Total_Length=Total_Time_us * 1e3 * SamplesPerMicrosecond;
% ini_value=zeros(Total_Length,1);

%% 测量过程
% fid = fopen([file_out.path,'\test.dat'],'w');%输出文件名

for t_empty = 10:15    %扫描参数/from/step/to
    %     file = CFile('E:\people\HRZ\data\T1\test\');
    % path=file.folder.getCurrentPath();
    
    
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
    
    arbTo33500(arb,IP,V_amp,sRate,name);
    pause(1);
    %%
    
    count = 0;% readout计数
%     data = inst_Digitizer.acquire(VoltageAmplitude);
%     for j = 1 : RepeatCount
%         file.save([time' data.CHA(j,:)']);%导出数据
%         for k = 1 : SampleCount
%             if data.CHA(j,k) > threshold
%                 count = count + 1;%比较阈值，超过则计数+1，并跳出循环
%                 break;
%             end
%         end
%     end
%     fprintf(fid,'%f\t%f\r\n',i*TimeSpace-TimeSpace,count/RepeatCount);%导出最终曲线
end
% fclose(fid);
% file.close();
%% 数据存储
% file_out.save([t' prob']);%导出数据
% figure;%画图
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

