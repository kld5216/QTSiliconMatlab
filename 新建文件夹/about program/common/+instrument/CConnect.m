classdef CConnect < handle
    %CCONNECT 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties(Access = public)
        instObj;
        address;
    end
    
    methods
        function obj = CConnect(address)            
            obj.address = address;              
            if ischar(address)                
                obj.instObj = instrfind('Type', 'visa-tcpip', 'RsrcName', obj.address, 'Tag', '');
                
                if isempty(obj.instObj)
                    obj.instObj = visa('AGILENT', obj.address);
                else
                    fclose(obj.instObj);
                    obj.instObj = obj.instObj(1);
                end
                
            else
                
                obj.instObj = instrfind('Type', 'gpib', 'BoardIndex', 7, 'PrimaryAddress', obj.address, 'Tag', '');
                
                if isempty(obj.instObj)
                    obj.instObj = gpib('AGILENT', 7, obj.address);
                else
                    fclose(obj.instObj);
                    obj.instObj = obj.instObj(1);
                end
                
            end
            
            fopen(obj.instObj);
        end
    end
    
end

