function write_parameter(InitList,dim,label,from,step,to,delay,repeat,labelsRead,filepath)
            import tool.*
            defaultMapPath = 'E:\MatlabGithub\toolbox\Defaults_para\Defaults_setting\map.txt';
            %% write instrument_param.txt
            instrfile = fullfile(filepath,'instrument_param.txt');
            fd = fopen(instrfile,'w');
            if fd == -1
                error('writeParameter:Error','Can not open %s\r\n',instrfile);
            else
                for j = 1:length(InitList)
                    instrument = InitList{j};
                    switch instrument.name
                        case {'lockin1','lockin2','lockin3'}
                            [~,idx] = find(cellfun(@(x) strcmp(x,'both'), instrument.operate_type));
                            labels = instrument.label(idx);
                            readers = arrayfun(@(x) instrument.operate('read',x),idx,'UniformOutput',0);
                            cellfun(@(x,y) fprintf(fd,'%s\t%g\r\n',x,y()),labels,readers);
                    end
                end
                fclose(fd);
            end
            %% write param_prev.txt
            param_prevfile = fullfile(filepath,'param_prev.txt');
            fd = fopen(param_prevfile,'w');
            if fd == -1
                error('writeParameter:Error','Can not open %s\r\n',param_prevfile);
            else
                title = sprintf('\t');
                content = '';
                for i = dim:-1:1
                    title = [title,sprintf('@Sweepgate{%s}',label{i})];
                    content = [content,sprintf('@Sweepgate{%s}(%g:%g:%g:%g:%g)',label{i},from(i),step(i),to(i),delay(i),repeat(i))];
                    if i > 1
                        title = [title,'-'];
                        content = [content,'  '];
                    else
                        title = [title,':'];
                        content = [content,sprintf('\r\n')];
                    end
                end
                index = zeros(1,length(labelsRead));
                for i = 1:length(labelsRead)
                    tokens = regexp(labelsRead{i},'Current(\d+)','tokens');
                    index(i) = str2double(tokens{1}{1});
                    tmp = regexprep(labelsRead{i},'Current(\d+)','@Current$1{Current$1}');
                    title = [title,tmp];
                    if i < length(labelsRead)
                        title = [title,'-'];
                    end
                end
                index = sort(unique(index));
                for i = 1:length(index)
                    content = [content,sprintf('@Current%d{Current%d}(@Bias%d  @Modulation%d  @Source%d  @Measure%d)',index(i),index(i),index(i),index(i),index(i),index(i))];
                    if i < length(index)
                        content = [content,'  '];
                    else
                        content = [content,sprintf('\r\n')];
                    end
                end
                fprintf(fd,'%s\r\n%s',title,content);
                for i = 1:length(InitList)
                    instrument = InitList{i};
                    switch instrument.name
                        case 'lockin1'
                            for j = 1:4
                                fprintf(fd,'A%g(%g)',j,instrument.read_aux(j));
                            end
                        case 'lockin2'
                            for j=1:4
                                fprintf(fd,'B%g(%g)',j,instrument.read_aux(j));
                            end
                        case 'lockin3'
                            for j=1:4
                                fprintf(fd,'C%g(%g)',j,instrument.read_aux(j));
                            end
                        case 'itek'
                            for j = 1:8                                
                                fprintf(fd,'U%d(%g)',j,instrument.read_volt(j));
                            end
                            fprintf(fd,'\r\n');
                            for j = 9:16                                
                                fprintf(fd,'U%g(%g)',j,instrument.read_volt(j));
                            end
                        case 'e8257d'
                            if instrument.query_output_state
                                fprintf(fd,'Rffreq(%gGHz)Rfpower(%gdBm)',instrument.read_freq,instrument.read_power);
                            end
                        case 'agilent81134a'
                            if instrument.query_dut_state
                                fprintf(fd,'PulseFreq(%gMHz)',instrument.read_freq);
                                if instrument.query_output_state(1)==1
                                    fprintf(fd,'Pw1(%gps)Amp1(%gmv)',instrument.read_width(1),instrument.read_amp(1));
                                end
                                if instrument.query_output_state(2)==1
                                    fprintf(fd,'Pw2(%gps)Amp2(%gmv)',instrument.read_width(2),instrument.read_amp(2));
                                end
                            end
                        case 'sm'
                            fprintf(fd,'BG(%g)',instrument.read_volt);
                        case 'is'
                            fprintf(fd,'Bias(%g)',instrument.read_volt);
                    end
                    fprintf(fd,'\r\n');
                end
                fprintf(fd,'\r\n%s',filepath);
                fclose(fd);
                %% generate map.txt&parameter.txt
                if exist(instrfile,'file')&&exist(param_prevfile,'file')
                    if exist(defaultMapPath,'file')
                        copyfile(defaultMapPath,filepath);
                        process_parameter_txt(param_prevfile,instrfile,defaultMapPath);
                    end
                end
            end
        end