function process_parameter_txt(paramfile,instrumentfile,mapfile )
  import java.util.Hashtable;
  instrument=Hashtable();
  fd=fopen(instrumentfile,'r');
  tmp=textscan(fd,'%s %s');
  fclose(fd);
  size=length(tmp{1});
  for i=1:size
      instrument.put(upper(tmp{1}{i}),upper(tmp{2}{i}));
  end
  map=Hashtable();
  fd=fopen(mapfile,'r');
  tmp=textscan(fd,'%s %s');
  fclose(fd);
  size=length(tmp{1});
  for i=1:size
      map.put(upper(tmp{1}{i}),upper(tmp{2}{i}));
  end
  fd=fopen(paramfile,'r');
  headline=fgets(fd);
  remain=fscanf(fd,'%c');
  fclose(fd);
  expr='@([A-Za-z]+)(\d*){(.*?)}';
  [match,tokens]=regexp(headline,expr,'match','tokens');
  l=length(match);%match count;
  for i=1:l
      type=upper(tokens{i}{1});
      switch type
          case 'SWEEPGATE'
                label=upper(tokens{i}{3});
                name=map.get(label);
                if isempty(name)
                    name=label;
                end
                headline=regexprep(headline,match{i},name,'ignorecase');
                remain=regexprep(remain,match{i},name,'ignorecase');
          case 'CURRENT'
              label=upper(tokens{i}{3});
              num=tokens{i}{2};
              name=map.get(label);
              if isempty(name)
                  name=label;
              end
              headline=regexprep(headline,match{i},name,'preservecase');
              remain=regexprep(remain,match{i},name,'preservecase');
              bias=map.get(['BIAS',num]);
              if strcmpi(bias,'NON')||isempty(bias)
                  bias='';
                  remain=regexprep(remain,['@BIAS',num],bias,'ignorecase');
              else
                  remain=regexprep(remain,['@BIAS',num],sprintf('bias:%s',bias),'ignorecase');
              end
              
              modulation=map.get(['MODULATION',num]);
              if strcmpi(modulation,'NON')||isempty(modulation)
                  modulation='';
                  remain=regexprep(remain,['@MODULATION',num],'','ignorecase');
              else
                remain=regexprep(remain,['@MODULATION',num],sprintf('modulation@%s',modulation),'ignorecase');
              end
              source=map.get(['SOURCE',num]);
             if ~isempty(source)&&~strcmpi(source,'NON')
              tok=regexp(source,'([a-zA-Z]+)(\d*)','tokens');
              instrname=upper(tok{1}{1});
              instrnum=upper(tok{1}{2});
              sourcetype=0;%1 for lockin
              isfreqsexist=1;
              switch instrname
                  case 'LOCKIN'
                      sourcetype=1;
                      sinfo='';
                      [ratio,status1]=str2num(char(map.get(['RATIO',num])));
                      [amps,status2]=str2num(char(instrument.get(['AMP',instrnum])));
                      if status1&&status2
                          sinfo=[sinfo,sprintf('amps:%g ',amps*ratio)];
                      end
                      freqs=instrument.get(['FREQ',instrnum]);
                      if ~isempty(freqs)
                         
                        sinfo=[sinfo,sprintf('freqs:%s',freqs)];
                      else
                           isfreqsexist=0;
                      end
                      remain=regexprep(remain,['@SOURCE',num],sinfo,'ignorecase');
                  otherwise
                      sourcetype=0;
                      remain=regexprep(remain,['@SOURCE',num],'','ignorecase');
                      
              end
             else
                 remain=regexprep(remain,['@SOURCE',num],'','ignorecase');
             end
               measure=map.get(['MEASURE',num]);
              if ~isempty(measure)&&~strcmpi(measure,'NON')
               tok=regexp(measure,'([a-zA-Z]+)(\d*)','tokens');
               instrname=upper(tok{1}{1});
               instrnum=upper(tok{1}{2});
                switch instrname
                  case 'LOCKIN'
                      minfo='';
                      ampm=instrument.get(['AMP',instrnum]);
                      if ~isempty(ampm)
                          minfo=[minfo,sprintf('ampm:%s ',ampm)];
                      end
                      freqm=instrument.get(['FREQ',instrnum]);
                      if ~isempty(freqm)&&isfreqsexist
                        minfo=[minfo,sprintf('freqm:%s',freqm)];
                      end
                      remain=regexprep(remain,['@MEASURE',num],minfo,'ignorecase');
                    otherwise
                      remain=regexprep(remain,['@MEASURE',num],'','ignorecase');  
                end
              else
                  remain=regexprep(remain,['@MEASURE',num],'','ignorecase');  
              end
              
          
      end
      
          
  end
   expr='(\w+)\((.*?)\)';
  [match,tokens]=regexp(remain,expr,'match','tokens');
  l=length(match);%match count;
  for i=1:l
       label=upper(tokens{i}{1});
        name=map.get(label);
        if strcmpi(name,'non')
             remain=regexprep(remain,sprintf('%s\\(%s\\)',tokens{i}{1},tokens{i}{2}),'','ignorecase');
        else
         if isempty(name)
             name=label;
         end
                
          remain=regexprep(remain,label,name,'ignorecase');
        end
  end
  [path,~,~]=fileparts(paramfile);
  filename=fullfile(path,'param.txt');
  fd=fopen(filename,'w');
  fprintf(fd,'%s',headline);
  fprintf(fd,'%s',remain);
  fclose(fd);


end

