classdef CGPIB < instrument.CConnect
    %CGPIB �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
%         instObj;
%         address;
    end
    
    methods
        function obj = CGPIB(address)
%             obj.address = address;
%             obj.instObj = instrfind('Type', 'gpib', 'BoardIndex', 7, 'PrimaryAddress', obj.address, 'Tag', '');
%             if isempty(obj.instObj)
%                 obj.instObj = gpib('AGILENT', 7, obj.address);
%             else
%                 fclose(obj.instObj);
%                 obj.instObj = obj.instObj(1);
%             end
%             fopen(obj.instObj);
            obj = obj@instrument.CConnect(address);
        end
    end
    
end

