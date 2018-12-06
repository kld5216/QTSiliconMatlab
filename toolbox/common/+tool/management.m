function instrlist = management()
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
import real_instrument.*
InstrInFile = readtable('.\Defaults_para\Defaults_setting\instrlist.txt','Format','%s%s%s%s%s','Delimiter','space');
InstrInFile = table2cell(InstrInFile);
instrlist = cell(size(InstrInFile,1),2);
for i = 1:size(InstrInFile,1)
    address = strsplit(InstrInFile{i,3},',');
    switch address{1}
        case {'VISA-GPIB','GPIB'}
            address{2} = str2double(address{2});
    end
    address{3} = str2double(address{3});
    switch InstrInFile{i,5}
        case 'real'
            instrlist{i,1} = eval([InstrInFile{i,4} '(address,''.\Defaults_para\Defaults_setting\instr_para\' InstrInFile{i,2} ''')']);
            instrlist{i,2} = InstrInFile{i,1};
    end
end



