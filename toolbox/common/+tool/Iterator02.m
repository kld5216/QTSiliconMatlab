classdef Iterator02<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties
        func;
        from;
        step;
        to;
        delay;
        label;
        resetStep;
        resetDelay;
        repeat;
        curRepeat;
        nextFresh;%indicate the next value is a new value or repeat the current one;
        nextValue;
        curValue;
        started;
    end
    
    methods
        function iterator=Iterator02(func,from,step,to,delay,label,repeat,resetStep,resetDelay)
            iterator.func=func;
            iterator.from=from;
            iterator.step=abs(step)*sign(to-from);
            iterator.to=to;
            iterator.delay=delay;
            if ~exist('resetDelay','var')
                resetDelay=delay/3;
            end
            if ~exist('resetStep','var')
                resetStep=step*3;
            end
            if ~exist('repeat','var')
                repeat=1;
            end
            if ~exist('label','var')
                iterator.label='Sweep';
            else
                iterator.label=label;
            end
            iterator.repeat=repeat;
            iterator.resetStep=abs(resetStep)*sign(to-from);
            iterator.resetDelay=resetDelay;
            iterator.nextValue=from;
            iterator.curValue=[];
            iterator.started=0;
            iterator.nextFresh=1;
            iterator.curRepeat=0;
        end
        function nextVal=next(iterator)
            iterator.started=1;
            if iterator.nextFresh
                if abs(iterator.nextValue-iterator.from)>abs(iterator.to-iterator.from)
                    nextVal=[];
                    iterator.curValue=[];
                    iterator.curRepeat=0;
                else
                    iterator.func(iterator.nextValue);
                    pause(iterator.delay);
                    nextVal=iterator.nextValue;
                    iterator.curValue=nextVal;
                    iterator.nextValue=iterator.nextValue+iterator.step;
                    iterator.curRepeat=1;
                    if iterator.curRepeat<iterator.repeat
                        iterator.nextFresh=0;
                    end
                end
            else
                nextVal=iterator.curValue;
                pause(iterator.delay);
                iterator.curRepeat=iterator.curRepeat+1;
                if iterator.curRepeat>=iterator.repeat
                    iterator.nextFresh=1;
                end
            end
        end
        function curVal=reset(iterator)
            currentValue = iterator.nextValue-iterator.step;
            for i = currentValue:-iterator.resetStep:iterator.from
                iterator.func(i);
                pause(iterator.resetDelay);
            end
            iterator.func(iterator.from);
            pause(iterator.resetDelay);
            iterator.nextValue=iterator.from;
            curVal=iterator.from;
            iterator.started=0;
            iterator.curValue=[];
            iterator.curRepeat=0;
            iterator.nextFresh=1;
        end
        function description=get_short_description(iterator)
            description=sprintf('@Sweepgate{%s}',iterator.label);
        end
        function description=get_long_description(iterator)
            description=sprintf('@Sweepgate{%s}(%g:%g:%g:%g:%g)',iterator.label,iterator.from,iterator.step,iterator.to,iterator.delay,iterator.repeat);
        end
    end
end

