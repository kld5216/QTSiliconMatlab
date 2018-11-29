classdef CFolder < handle
    %CFOLDER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        basePath = '';%�����·��
        workPath = '';%����·����������������½���·����Ĭ������������
        currentPath = '';%��ǰ·��
    end
    
    methods
        function obj = CFolder(basePath,varargin)
           %%
            if(basePath(length(basePath))=='\')
                
            else
                errorMsg('�ļ���·��û��"\"');
            end
            obj.basePath = basePath;
           %%
            if nargin==1%eg : E:\data\2017-03-19 19.16.56\
                obj.workPath = [obj.basePath datestr(now,'yyyy-mm-dd HH.MM.SS') '\'];
            elseif nargin==2 %eg : E:\data\2017-03-19 19.17.49 JZL\
                obj.workPath = [obj.basePath datestr(now,'yyyy-mm-dd HH.MM.SS') ' ' varargin{1} '\'];
            elseif nargin==3 %eg : E:\data\JZL\
                if(isnumeric(varargin{2}) || islogical(varargin{2}))
                    if(varargin{2}==true)%eg : E:\data\JZL\
                        obj.workPath = [obj.basePath varargin{1} '\'];
                    else%eg : E:\data\2017-03-19 19.17.49 JZL\
                        obj.workPath = [obj.basePath datestr(now,'yyyy-mm-dd HH.MM.SS') ' ' varargin{1} '\'];
                    end
                elseif(ischar(varargin{2}))%eg : E:\data\JZL-DP\
                        obj.workPath = [obj.basePath varargin{1} '-' varargin{2} '\'];
                end
            elseif nargin==4 %file = CFile('E:\JZL\data\hehe\jiazhilong\','JZL','time','ON/OFF');
                if(strcmp(varargin{2},'time'))
                    if(strcmp(varargin{3},'ON'))% E:\JZL\data\hehe\jiazhilong\2017-03-19 19.17.49 JZL\
                        obj.workPath = [obj.basePath datestr(now,'yyyy-mm-dd HH.MM.SS') ' ' varargin{1} '\'];
                    elseif(strcmp(varargin{3},'OFF'))% E:\JZL\data\hehe\jiazhilong\JZL\
                        obj.workPath = [obj.basePath varargin{1} '\'];
                    else
                        errorMsg('�ļ��в������� ON/OFF');
                    end
                else
                    errorMsg('�ļ��в������� time');
                end
            end
            %%
            if ~exist(obj.workPath,'dir') 
                sys_order = ['mkdir "' obj.workPath '"'];
                system(sys_order);
            end
            
            obj.currentPath = obj.workPath;
            
        end
        function  create(obj,pathdata)
            obj.currentPath = obj.workPath;
            for i=1:numel(pathdata)
                obj.currentPath = [obj.currentPath, pathdata{i}, '\'];
                if ~exist(obj.currentPath) 
                    mkdir(obj.currentPath)
                end 
%                 sys_order = ['mkdir "' obj.currentPath '"'];
%                 system(sys_order);
            end
        end
        function path = getCurrentPath(obj)
            path = obj.currentPath;
        end
    end
    
end

