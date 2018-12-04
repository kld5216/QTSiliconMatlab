classdef FileWriter<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileNameFmt='';% 文件名
        writefmt='';% 写入的数据格式
        fileNameParam=[]; % 记录扫描位置
        path; % 文件路径
        fd; % 文件句柄
        dims;%sweep dim
        dimw;%number of write values
        isFdValid; % 文件是否已打开
        curFilename; % 当前文件名
        filenamefor1D='1.dat';
    end
    
    methods
        function fw=FileWriter(dims,dimw,path)
            fw.dims=dims;
            fw.dimw=dimw;
            fw.path=path;
            if ~exist(path,'dir')
                mkdir(path);
            end
            for i=1:dims-2
                fw.fileNameFmt=[fw.fileNameFmt,'%d-%d\\'];
            end
            fw.fileNameFmt=[fw.fileNameFmt,'%d-%d.dat'];
            fw.fileNameParam=ones(1,2*(dims-1));
            for i=1:dimw-1
                fw.writefmt=[fw.writefmt,'%g\t'];
            end
            fw.writefmt=[fw.writefmt,'%g\r\n'];            
            fw.isFdValid=0;
        end
        function reset(fw,dim,component)
            if fw.isFdValid
              fclose(fw.fd);
              fw.isFdValid=0;
            end
            if ~exist('component','var')
                component=1;
            end
            if fw.dims~=1
                if dim~=0
                    if component == 1
                      fw.fileNameParam(2*dim-1) = fw.fileNameParam(2*dim-1) + 1;
                      fw.fileNameParam(2*dim) = 1;
                    elseif component == 2
                      fw.fileNameParam(2*dim) = fw.fileNameParam(2*dim) + 1;
                    end
                end
                for i=2*dim+1:2*(fw.dims-1)
                    fw.fileNameParam(i) = 1;
                end
            end
        end
        function write(fw,sVal,rVal)
            if ~fw.isFdValid
                if fw.dims==1
                    fw.curFilename=fw.filenamefor1D;
                else
                    fw.curFilename=sprintf(fw.fileNameFmt,fw.fileNameParam(:));
                end
                fullfilename=fullfile(fw.path,fw.curFilename);
                [folder,~,~]=fileparts(fullfilename);
                if ~exist(folder,'dir')
                    mkdir(folder);
                end
                fw.fd=fopen(fullfilename,'w');
                fw.isFdValid=1;       
            end
            fprintf(fw.fd,fw.writefmt,sVal{:},rVal{:});
        end
        function delete(fw)
            if fw.isFdValid
                fclose(fw.fd);
                fw.isFdValid=0;
            end
        end
    end
    
end

