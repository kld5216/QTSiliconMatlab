function write_parameter(app)
instrfile = fullfile(app.filePath,'instrument_param.txt');
fd = fopen(instrfile,'w');
if fd == -1
    fprintf(1,'Can not open %s\r\n',instrfile);
else
    flag = 0;
    for j = 1:length(app.InstrDropDown.Items)
        switch app.InstrDropDown.Items{j}
            case 'lockin 1'
                if app.lockin1.isopened
                    flag = 1;
                else
                    flag = 0;
                    app.lockin1.open;
                end
                for i = 1:4
                    fprintf(fd,'A%g\t%g\r\n',i,app.lockin1.read_aux(i));
                end
                fprintf(fd,'AMP1\t%g\r\n',app.lockin1.read_amp());
                fprintf(fd,'FREQ1\t%g\r\n',app.lockin1.read_freq());
                if ~flag
                    app.lockin1.close;
                end
                
            case 'lockin 2'
                if app.lockin2.isopened
                    flag = 1;
                else
                    flag = 0;
                    app.lockin2.open;
                end
                for i = 1:4
                    fprintf(fd,'B%g\t%g\r\n',i,app.lockin2.read_aux(i));
                end
                fprintf(fd,'AMP2\t%g\r\n',app.lockin2.read_amp());
                fprintf(fd,'FREQ2\t%g\r\n',app.lockin2.read_freq());
                if ~flag
                    app.lockin2.close;
                end
            case 'lockin 3'
                if app.lockin3.isopened
                    flag = 1;
                else
                    flag = 0;
                    app.lockin3.open;
                end
                for i = 1:4
                    fprintf(fd,'C%g\t%g\r\n',i,app.lockin3.read_aux(i));
                end
                fprintf(fd,'AMP3\t%g\r\n',app.lockin3.read_amp());
                fprintf(fd,'FREQ3\t%g',app.lockin3.read_freq());
                if ~flag
                    app.lockin3.close;
                end
        end
    end
    fclose(fd);
end

param_prevfile=fullfile(app.filePath,'param_prev.txt');
fd = fopen(param_prevfile,'w');
if fd == -1
    fprintf(1,'Can not open %s\r\n',param_prevfile);
else
    
    title = sprintf('\t');
    content = '';
    for i = 1:app.dim
        title = [title,app.iterators{i}.get_short_description];
        content = [content,app.iterators{i}.get_long_description]; %#ok<*AGROW>
        
        if i < app.dim
            title = [title,'-'];
            content = [content,'  '];
        else
            title = [title,':'];
            content = [content,sprintf('\r\n')];
        end
    end
    index = zeros(1,length(app.labelsRead));
    for i = 1:length(app.labelsRead)
        tokens = regexp(app.labelsRead{i},'Current(\d+)','tokens');
        index(i) = str2num(tokens{1}{1});
        tmp = regexprep(app.labelsRead{i},'Current(\d+)','@Current$1{Current$1}');
        title = [title,tmp];
        if i < length(app.labelsRead)
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
    
    flag = 0; %#ok<*NASGU>
    for i = 1:length(app.InstrDropDown.Items)
        switch app.InstrDropDown.Items{i}
            case 'lockin 1'
                if app.lockin1.isopened
                    flag=1;
                else
                    flag=0;
                    app.lockin1.open();
                end
                for j = 1:4
                    fprintf(fd,'A%g(%g)',j,app.lockin1.read_aux(j));
                end
                if ~flag
                    app.lockin1.close();
                end
            case 'lockin 2'
                if app.lockin2.isopened
                    flag=1;
                else
                    flag=0;
                    app.lockin2.open;
                end
                for j=1:4
                    fprintf(fd,'B%g(%g)',j,app.lockin2.read_aux(j));
                end
                if ~flag
                    app.lockin2.close;
                end
            case 'lockin 3'
                if app.lockin3.isopened
                    flag=1;
                else
                    flag=0;
                    app.lockin3.open;
                end
                for j=1:4
                    fprintf(fd,'C%g(%g)',j,app.lockin3.read_aux(j));
                end
                if ~flag
                    app.lockin3.close;
                end
            case 'itek'
                if app.itek.isopened
                    flag = 1;
                else
                    flag = 0;
                    app.itek.open;
                end
                for j = 1:8
                    %                                 label = sprintf('U%d',j);
                    label = ['I',char(65+floor((j-1)/4)),num2str(j-floor((j-1)/4)*4)];
                    fprintf(fd,'%s(%g)',label,app.itek.query_volt(j));
                end
                fprintf(fd,'\r\n');
                for j = 9:16
                    %                                 label = sprintf('U%d',j);
                    label = ['I',char(65+floor((j-1)/4)),num2str(j-floor((j-1)/4)*4)];
                    fprintf(fd,'%s(%g)',label,app.itek.query_volt(j));
                end
                if ~flag
                    app.itek.close;
                end
            case 'e8257d'
                if app.e8257d.isopened
                    flag=1;
                else
                    flag=0;
                    app.e8257d.open;
                end
                if app.e8257d.query_output_state
                    fprintf(fd,'Rffreq(%gGHz)Rfpower(%gdBm)',app.e8257d.query_freq,app.e8257d.query_power);
                end
                if ~flag
                    app.e8257d.close;
                end
            case 'agilent81134a'
                if app.agilent81134a.isopened
                    flag=1;
                else
                    flag=0;
                    app.agilent81134a.open;
                end
                if app.agilent81134a.query_dut_state
                    fprintf(fd,'PulseFreq(%gMHz)',app.agilent81134a.query_freq);
                    if app.agilent81134a.query_output_state(1)==1
                        fprintf(fd,'Pw1(%gps)Amp1(%gmv)',app.agilent81134a.query_width(1),app.agilent81134a.query_amp(1));
                    end
                    if app.agilent81134a.query_output_state(2)==1
                        fprintf(fd,'Pw2(%gps)Amp2(%gmv)',app.agilent81134a.query_width(2),app.agilent81134a.query_amp(2));
                    end
                end
                if ~flag
                    app.agilent81134a.close;
                end
            case 'sm'
                if app.sm.isopened
                    flag=1;
                else
                    flag=0;
                    app.sm.open;
                end
                fprintf(fd,'BG(%g)',app.sm.query_volt);
                
                if ~flag
                    app.sm.close;
                end
            case 'is','var')
                if app.sim.isopened
                    flag=1;
                else
                    flag=0;
                    app.sim.open;
                end
                fprintf(fd,'Bias(%g)',app.is.read_volt);
                
                if ~flag
                    app.sim.close;
                end
        end
    end
    fprintf(fd,'\r\n');
    fprintf(fd,'\r\n%s',app.filePath);
    fclose(fd);
    if exist(instrfile,'file')&&exist(param_prevfile,'file')
        if exist(app.defaultMapPath,'file')
            copyfile(app.defaultMapPath,app.filePath);
            process_parameter_txt03(param_prevfile,instrfile,app.defaultMapPath);
        end
    end
end
end