classdef CLAN < instrument.CConnect
    %CLAN 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
%         instObj;
%         address;
    end
    
    methods
        function obj = CLAN(address)
%             obj.address = address;
%             % Find a VISA-TCPIP object.
%             obj.instObj = instrfind('Type', 'visa-tcpip', 'RsrcName', obj.address, 'Tag', '');
%             % Create the VISA-TCPIP object if it does not exist
%             % otherwise use the object that was found.
%             if isempty(obj.instObj)
%                 obj.instObj = visa('AGILENT', obj.address);
%             else
%                 fclose(obj.instObj);
%                 obj.instObj = obj.instObj(1);
%             end
%             % Connect to instrument object, obj1.
%             fopen(obj.instObj);
            obj = obj@instrument.CConnect(address);
        end
    end
    
end

