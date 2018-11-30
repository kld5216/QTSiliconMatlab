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
        resetmode;%0 for jump,1 for slowly change
        resetStep;
        resetDelay;
        repeat;
        curRepeat;
        nextFresh;%indicate the next value is a new value or repeat the current one;
        funcAssoc;
        fromAssoc;
        slope;
        labelAssoc;
        nextValue;
        nextValueAssoc;
        curValue;
        hasAssoc;
        started;
     end
    
    methods
        function iterator=Iterator02(func,from,step,to,delay,label,repeat,resetmode,resetStep,resetDelay)
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
                 if ~exist('resetmode','var')
                     resetmode=1;
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
                 iterator.resetmode=resetmode;
                 iterator.resetStep=abs(resetStep)*sign(to-from);
                 iterator.resetDelay=resetDelay;
                 iterator.nextValue=from;
                 iterator.curValue=[];
                 iterator.funcAssoc={};
                 iterator.fromAssoc=[];
                 iterator.slope=[];
                 iterator.labelAssoc={};
                 iterator.nextValueAssoc=[];
                 iterator.started=0;
                 iterator.hasAssoc=0;
                 iterator.nextFresh=1;
                 iterator.curRepeat=0;
        end
        function addAssoc(iterator,funcAssoc,fromAssoc,slope,label)
            if iterator.started
                return;
            end
            iterator.hasAssoc=iterator.hasAssoc+1;
            iterator.funcAssoc{iterator.hasAssoc}=funcAssoc;
            iterator.fromAssoc(iterator.hasAssoc)=fromAssoc;
            iterator.slope(iterator.hasAssoc)=slope;
            if ~exist('label','var')
                iterator.labelAssoc{iterator.hasAssoc}=sprintf('Assoc%d',iterator.hasAssoc);
            else
                iterator.labelAssoc{iterator.hasAssoc}=label;
            end
            iterator.nextValueAssoc(iterator.hasAssoc)=fromAssoc;
            
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
                       for i=1:iterator.hasAssoc
                        iterator.funcAssoc{i}(iterator.nextValueAssoc(i));
                       end
                       pause(iterator.delay);
                       nextVal=[iterator.nextValue iterator.nextValueAssoc];
                       iterator.curValue=nextVal;
                       iterator.nextValue=iterator.nextValue+iterator.step;
                      if iterator.hasAssoc
                         iterator.nextValueAssoc=iterator.nextValueAssoc+iterator.step*iterator.slope;
                      end
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
            currentValue=iterator.nextValue-iterator.step;
            if iterator.resetmode==1
              for i=currentValue:-iterator.resetStep:iterator.from
                    iterator.func(i);
                    if iterator.hasAssoc
                     tmp=(i-iterator.from)*iterator.slope+iterator.fromAssoc;
                     for j=1:iterator.hasAssoc
                      iterator.funcAssoc{j}(tmp(j));
                     end
                    end
                    pause(iterator.resetDelay);
              end
           
            iterator.func(iterator.from);
            for i=1:iterator.hasAssoc
            iterator.funcAssoc{i}(iterator.fromAssoc(i));
            end
            pause(iterator.resetDelay);
           end
            iterator.nextValue=iterator.from;
            iterator.nextValueAssoc=iterator.fromAssoc;
            curVal=[iterator.from iterator.fromAssoc];
            iterator.started=0;
            iterator.curValue=[];
            iterator.curRepeat=0;
            iterator.nextFresh=1;
        end
        function description=get_short_description(iterator)
            description=sprintf('@Sweepgate{%s}',iterator.label);
            if iterator.hasAssoc
                p='';
                for i=1:iterator.hasAssoc-1
                    p=[p,sprintf('@Sweepgate{%s}',iterator.labelAssoc{i}),','];
                end
                p=[p,sprintf('@Sweepgate{%s}',iterator.labelAssoc{iterator.hasAssoc})];
                description=[description,'(',p,')'];
            end
            
        end
        function description=get_long_description(iterator)
             description=sprintf('@Sweepgate{%s}(%g:%g:%g:%g:%g)',iterator.label,iterator.from,iterator.step,iterator.to,iterator.delay,iterator.repeat);
             if iterator.hasAssoc
                 p='';
                 for i=1:iterator.hasAssoc
                     p=[p,sprintf('-@Sweepgate{%s}(%g:%g)',iterator.labelAssoc{i},iterator.fromAssoc(i),iterator.slope(i))];
                 end
                 description=[description,p];
             end
        end
        
        
    end
    
    
end

