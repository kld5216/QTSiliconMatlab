classdef Index_Sweep
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties(Access = public)
        label = '';
        setter;
        reader;
        resetmode = 0;
        resetStep = 1;
        resetDelay = 1;
    end
    
    methods
        function obj = Index_Sweep(app,Instr)
            switch Instr
                case 'lockin 1'
                    obj = obj(6);
                    instr = app.lockin1;
                    for j = 1:4
                        obj(j).label = sprintf('A%d',j);
                        obj(j).setter = @(val)(instr.set_aux(j,val));
                        obj(j).reader = @()(instr.read_aux(j));
                        obj(j).restmode = 1;
                        obj(j).resetStep = app.resetStepAux;
                        obj(j).resetDelay = app.resetDelayAux;
                    end
                    
                    obj(5).label = 'Freq1';
                    obj(5).setter = @(val)(instr.set_freq(0,val));
                    obj(5).reader = @()(instr.read_freq(0));
                    obj(5).resetmode = 1;
                    obj(5).resetStep = app.resetStepFreq;
                    obj(5).resetDelay = app.resetDelayFreq;
                    
                    obj(6).label = 'Amp1';
                    obj(6).setter = @(val)(instr.set_freq(0,val));
                    obj(6).reader = @()(instr.read_freq(0));
                    obj(6).resetmode = 1;
                    obj(6).resetStep = app.resetStepFreq;
                    obj(6).resetDelay = app.resetDelayFreq;
                    
                case 'lockin 2'
                    obj = obj(6);
                    instr = app.lockin2;
                    for j = 1:4
                        obj(j).label = sprintf('B%d',j);
                        obj(j).setter = @(val)(instr.set_aux(j,val));
                        obj(j).reader = @()(instr.read_aux(j));
                        obj(j).restmode = 1;
                        obj(j).resetStep = app.resetStepAux;
                        obj(j).resetDelay = app.resetDelayAux;
                    end
                    
                    obj(5).label = 'Freq2';
                    obj(5).setter = @(val)(instr.set_freq(0,val));
                    obj(5).reader = @()(instr.read_freq(0));
                    obj(5).resetmode = 1;
                    obj(5).resetStep = app.resetStepFreq;
                    obj(5).resetDelay = app.resetDelayFreq;
                    
                    obj(6).label = 'Amp2';
                    obj(6).setter = @(val)(instr.set_freq(0,val));
                    obj(6).reader = @()(instr.read_freq(0));
                    obj(6).resetmode = 1;
                    obj(6).resetStep = app.resetStepFreq;
                    obj(6).resetDelay = app.resetDelayFreq;
                    
                case 'lockin 3'
                    obj = obj(6);
                    instr = app.lockin3;
                    for j = 1:4
                        obj(j).label = sprintf('C%d',j);
                        obj(j).setter = @(val)(instr.set_aux(j,val));
                        obj(j).reader = @()(instr.read_aux(j));
                        obj(j).restmode = 1;
                        obj(j).resetStep = app.resetStepAux;
                        obj(j).resetDelay = app.resetDelayAux;
                    end
                    
                    obj(5).label = 'Freq3';
                    obj(5).setter = @(val)(instr.set_freq(0,val));
                    obj(5).reader = @()(instr.read_freq(0));
                    obj(5).resetmode = 1;
                    obj(5).resetStep = app.resetStepFreq;
                    obj(5).resetDelay = app.resetDelayFreq;
                    
                    obj(6).label = 'Amp3';
                    obj(6).setter = @(val)(instr.set_freq(0,val));
                    obj(6).reader = @()(instr.read_freq(0));
                    obj(6).resetmode = 1;
                    obj(6).resetStep = app.resetStepFreq;
                    obj(6).resetDelay = app.resetDelayFreq;
                    
                case 'e8257d'
                    obj = obj(2);
                    instr = app.e8257d;
                    
                    obj(1).label = 'Rffreq';
                    obj(1).setter = @(val)(instr.set_freq(0,val));
                    obj(1).reader = @()(instr.read_freq(0));
                    obj(1).restmode = 1;
                    obj(1).resetStep = app.resetsteprfFreq;
                    obj(1).resetDelay = app.resetdelayrfFreq;
                    
                    obj(2).label = 'Rfpower';
                    obj(2).setter = @(val)(instr.set_power(0,val));
                    obj(2).reader = @()(instr.read_power(0));
                    obj(2).resetmode = 1;
                    obj(2).resetStep = app.resetsteprfPower;
                    obj(2).resetDelay = app.resetdelayrfPower;
                    
                case 'agilent81134a'
                    obj = obj(6);
                    instr = app.agilent81134a;
                    
                    for j = 1:2
                        obj(j).label = sprintf('Pw%d',j);
                        obj(j).setter = @(val)(instr.set_width(j,val));
                        obj(j).reader = @()(instr.read_width(j));
                        obj(j).resetmode = 1;
                        obj(j).resetStep = app.resetPulsePwStep;
                        obj(j).resetDelay = app.resetPulsePwDelay;
                        
                        obj(j+2).label = sprintf('Amp%d',j);
                        obj(j+2).setter = @(val)(instr.set_amp(j,val));
                        obj(j+2).reader = @()(instr.read_amp(j));
                        obj(j+2).resetmode = 1;
                        obj(j+2).resetStep = app.resetPulseAmpStep;
                        obj(j+2).resetDelay = app.resetPulseAmpDelay;
                    end
                    
                    obj(5).label = 'PulseFreq';
                    obj(5).setter = @(val)(instr.set_freq(0,val));
                    obj(5).reader = @()(instr.read_freq(0));
                    obj(5).resetmode = 1;
                    obj(5).resetStep = app.resetPulseFreqStep;
                    obj(5).resetDelay = app.resetPulseFreqDelay;
                    
                    obj(6).label = 'PulsePeriod';
                    obj(6).setter = @(val)(instr.set_period(0,val));
                    obj(6).reader = @()(instr.read_period(0));
                    obj(6).resetmode = 1;
                    obj(6).resetStep = app.resetPulsePeriodStep;
                    obj(6).resetDelay = app.resetPulsePeriodDelay;
                    
                case 'a33522a'
                    obj = obj(3);
                    instr = app.a33522a;
                    
                    obj(1).label = 'SquareFreq';
                    obj(1).setter = @(val)(instr.set_freq(1,val));
                    obj(1).reader = @()(instr.read_freq(1));
                    obj(1).resetmode = 1;
                    obj(1).resetStep = app.resetSquareFreqStep;
                    obj(1).resetDelay = app.resetSquareFreqDelay;
                    
                    obj(2).label = 'SquareAmp';
                    obj(2).setter = @(val)(instr.set_amp(1,val));
                    obj(2).reader = @()(instr.read_amp(1));
                    obj(2).resetmode = 1;
                    obj(2).resetStep = app.resetSquareAmpStep;
                    obj(2).resetDelay = app.resetSquareAmpDelay;
                    
                    obj(3).label = 'SquarePeriod';
                    obj(3).setter = @(val)(instr.set_period(1,val));
                    obj(3).reader = @()(instr.read_period(1));
                    obj(3).resetmode = 1;
                    obj(3).resetStep = app.resetSquarePerStep;
                    obj(3).resetDelay = app.resetSquarePerDelay;
                    
                case 'sm'
                    obj = obj(2);
                    instr = app.sm;
                    
                    obj(1).label = 'BG';
                    obj(1).setter = @(val)(instr.set_volt(0,val));
                    obj(1).reader = @()(instr.read_volt(0));
                    obj(1).resetmode = 1;
                    obj(1).resetStep = app.resetsmStep;
                    obj(1).resetDelay = app.resetsmDelay;
                    
                    obj(2).label = 'I_source';
                    obj(2).setter = @(val)(instr.set_curr(0,val));
                    obj(2).reader = @()(instr.read_curr(0));
                    obj(2).resetmode = 1;
                    obj(2).resetStep = 0.05;
                    obj(2).resetDelay = 0.02;
                    
                case 'sim'
                    instr = app.sim;
                    obj.label = 'Bias_SD';
                    obj.setter = @(val)(instr.set_volt(0,val));
                    obj.reader = @()(instr.read_volt(0));
                    obj.resetmode = 1;
                    obj.resetStep = app.resetisStep;
                    obj.resetDelay = app.resetisDelay;
            end
        end
    end
end

