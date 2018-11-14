function SIndx = SweepIndex(app,Instr)
%UNTITLED3 此处显示有关此函数的摘要


switch Instr
    case 'lockin 1'
        instr = app.lockin1;
        SIndx = cell(6,6);
        for j = 1:4
            SIndx{1,j} = sprintf('A%d',j);
            SIndx{2,j} = @(val)(instr.set_aux(j,val));
            SIndx{3,j} = @()(instr.read_aux(j));
            SIndx{4,j} = 1;
            SIndx{5,j} = app.resetStepAux;
            SIndx{6,j} = app.resetDelayAux;
        end
        SIndx{1,5} = 'Freq1';
        SIndx{2,5} = @(val)(instr.set_freq(0,val));
        SIndx{3,5} = @()(instr.read_freq(0));
        SIndx{4,5} = 1;
        SIndx{5,5} = app.resetStepFreq;
        SIndx{6,5} = app.resetDelayFreq;
        
        SIndx{1,6} = 'Amp1';
        SIndx{2,6} = @(val)(instr.set_freq(0,val));
        SIndx{3,6} = @()(instr.read_freq(0));
        SIndx{4,6} = 1;
        SIndx{5,6} = app.resetStepFreq;
        SIndx{6,6} = app.resetDelayFreq;
        
    case 'lockin 2'
        instr = app.lockin2;
        SIndx = cell(6,6);
        for j = 1:4
            SIndx{1,j} = sprintf('B%d',j);
            SIndx{2,j} = @(val)(instr.set_aux(j,val));
            SIndx{3,j} = @()(instr.read_aux(j));
            SIndx{4,j} = 1;
            SIndx{5,j} = app.resetStepAux;
            SIndx{6,j} = app.resetDelayAux;
        end
        SIndx{1,5} = 'Freq2';
        SIndx{2,5} = @(val)(instr.set_freq(0,val));
        SIndx{3,5} = @()(instr.read_freq(0));
        SIndx{4,5} = 1;
        SIndx{5,5} = app.resetStepFreq;
        SIndx{6,5} = app.resetDelayFreq;
        
        SIndx{1,6} = 'Amp2';
        SIndx{2,6} = @(val)(instr.set_freq(0,val));
        SIndx{3,6} = @()(instr.read_freq(0));
        SIndx{4,6} = 1;
        SIndx{5,6} = app.resetStepFreq;
        SIndx{6,6} = app.resetDelayFreq;
        
    case 'lockin 3'
        instr = app.lockin3;
        SIndx = cell(6,6);
        for j = 1:4
            SIndx{1,j} = sprintf('C%d',j);
            SIndx{2,j} = @(val)(instr.set_aux(j,val));
            SIndx{3,j} = @()(instr.read_aux(j));
            SIndx{4,j} = 1;
            SIndx{5,j} = app.resetStepAux;
            SIndx{6,j} = app.resetDelayAux;
        end
        SIndx{1,5} = 'Freq3';
        SIndx{2,5} = @(val)(instr.set_freq(0,val));
        SIndx{3,5} = @()(instr.read_freq(0));
        SIndx{4,5} = 1;
        SIndx{5,5} = app.resetStepFreq;
        SIndx{6,5} = app.resetDelayFreq;
        
        SIndx{1,6} = 'Amp3';
        SIndx{2,6} = @(val)(instr.set_freq(0,val));
        SIndx{3,6} = @()(instr.read_freq(0));
        SIndx{4,6} = 1;
        SIndx{5,6} = app.resetStepFreq;
        SIndx{6,6} = app.resetDelayFreq;
        
    case 'e8257d'
        instr=app.e8257d;
        SIndx = cell(6,2);
        
        SIndx{1,1} = 'Rffreq';
        SIndx{2,1} = @(val)(instr.set_freq(0,val));
        SIndx{3,1} = @()(instr.read_freq(0));
        SIndx{4,1} = 1;
        SIndx{5,1} = app.resetsteprfFreq;
        SIndx{6,1} = app.resetdelayrfFreq;
        
        SIndx{1,2} = 'Rfpower';
        SIndx{2,2} = @(val)(instr.set_power(0,val));
        SIndx{3,2} = @()(instr.read_power(0));
        SIndx{4,2} = 1;
        SIndx{5,2} = app.resetsteprfPower;
        SIndx{6,2} = app.resetdelayrfPower;
        
    case 'agilent81134a'
        instr=app.agilent81134a;
        SIndx = cell(6,6);
        for j = 1:2
            SIndx{1,j} = sprintf('Pw%d',j);
            SIndx{2,j} = @(val)(instr.set_width(j,val));
            SIndx{3,j} = @()(instr.read_width(j));
            SIndx{4,j} = 1;
            SIndx{5,j} = app.resetPulsePwStep;
            SIndx{6,j} = app.resetPulsePwDelay;
            
            SIndx{1,j+2} = sprintf('Amp%d',j);
            SIndx{2,j+2} = @(val)(instr.set_amp(j,val));
            SIndx{3,j+2} = @()(instr.read_amp(j));
            SIndx{4,j+2} = 1;
            SIndx{5,j+2} = app.resetPulseAmpStep;
            SIndx{6,j+2} = app.resetPulseAmpDelay;
        end
        
        SIndx{1,5} = 'PulseFreq';
        SIndx{2,5} = @(val)(instr.set_freq(0,val));
        SIndx{3,5} = @()(instr.read_freq(0));
        SIndx{4,5} = 1;
        SIndx{5,5} = app.resetPulseFreqStep;
        SIndx{6,5} = app.resetPulseFreqDelay;
        
        SIndx{1,6} = 'PulsePeriod';
        SIndx{2,6} = @(val)(instr.set_period(0,val));
        SIndx{3,6} = @()(instr.read_period(0));
        SIndx{4,6} = 1;
        SIndx{5,6} = app.resetPulsePeriodStep;
        SIndx{6,6} = app.resetPulsePeriodDelay;
        
    case 'a33522a'
        instr=app.a33522a;
        
        SIndx{1,1} = 'SquareFreq';
        SIndx{2,1} = @(val)(instr.set_freq(1,val));
        SIndx{3,1} = @()(instr.read_freq(1));
        SIndx{4,1} = 1;
        SIndx{5,1} = app.resetSquareFreqStep;
        resetDelay=app.resetSquareFreqDelay;
end
end