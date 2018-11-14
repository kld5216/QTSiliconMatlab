classdef CFile < handle
    %CFILE 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        folder = [];
        basePath = '';
        path = '';
        ID = 0;
    end
    
    methods
        function obj = CFile(basePath,varargin)
            import tool.*;
            obj.basePath = basePath;
            if(nargin==1)
                obj.folder = CFolder(obj.basePath);
            elseif(nargin==2)
                obj.folder = CFolder(obj.basePath,varargin{1});
            elseif(nargin==3)
                obj.folder = CFolder(obj.basePath,varargin{1},varargin{2});
            elseif(nargin==4)
                obj.folder = CFolder(obj.basePath,varargin{1},varargin{2},varargin{3});
            end
            obj.ID = 1;
            obj.path = obj.folder.getCurrentPath();
        end
        
        function changeFolder(obj,varargin)
            obj.folder.create(varargin);
            obj.ID = 1;
            obj.path = obj.folder.getCurrentPath();
        end
        
        function path = getCurrentPath(obj)
            path = obj.path;
        end
        
        function save(obj,data,varargin)
            if nargin==2
                save([obj.folder.getCurrentPath() num2str(obj.ID) '.dat'],'data','-ascii');
                obj.ID = obj.ID+1;
            elseif nargin==3
                filename = varargin{1};
                if(isempty(strfind(filename,'.dat')) == 0)
                    save([obj.path filename],'data','-ascii');
                elseif(isempty(strfind(filename,'.txt')) == 0)
                    save([obj.path filename],'data','-ascii');
                elseif(isempty(strfind(filename,'.csv')) == 0)
                    save([obj.path filename],'data','-ascii');
                else
                    save([obj.path filename '.dat'],'data','-ascii');
                end
            end
        end
        
        function saveByName(obj,data,filename)% AWG里面调用了
            save([obj.path filename],'data','-ascii');
        end
        function fprintf(obj,data)
            fid=fopen([obj.folder.getCurrentPath() num2str(obj.ID) '.dat'],'w');
            [~,n] = size(data);
            str = '';
            str_end = '\r\n';
            for i=1:n
                if i<n
                    str = [str '%e\t'];
                else
                    str = [str '%e'];
                end
            end
            str = [str str_end];
            fprintf(fid,str,data);
            fclose(fid);
            obj.ID = obj.ID+1;
        end
        function writeParaLine(obj,str)%写一行参数
            fid=fopen([obj.folder.getCurrentPath() 'parameter.txt'],'a');
            fprintf(fid,str);
            fprintf(fid,'\r\n');
            fclose(fid);
        end
    end
    
end

