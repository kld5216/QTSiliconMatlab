function instrlist = management()
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
import real_instrument.*
import instrument.*
idx = [];
InstrInFile = readtable('.\Defaults_para\Defaults_setting\instrlist.txt','Format','%s%s%s%s%s%s','Delimiter','space','ReadVariableNames',0);
InstrInFile = table2cell(InstrInFile);
instrlist = cell(size(InstrInFile,1),1);
for i = 1:size(InstrInFile,1)
    address = strsplit(InstrInFile{i,3},',');
    switch address{1}
        case {'VISA-GPIB','GPIB'}
            address{2} = str2double(address{2});
    end
    address{3} = str2double(address{3});
    switch InstrInFile{i,5}
        case 'real'
            if strcmp(InstrInFile{i,6},'1')
                instrlist{i} = eval([InstrInFile{i,4} '(InstrInFile{i,1},address,''.\Defaults_para\Defaults_setting\instr_para\' InstrInFile{i,2} ''')']);
            else
                idx = [idx i];
            end
    end
end
if ~isempty(idx)
    instrlist(idx) = [];
end



