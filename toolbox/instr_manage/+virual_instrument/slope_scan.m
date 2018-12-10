classdef slope_scan<handle
    %����Ӳ�����ͨһ�����������ɺ����Ͳ�������
    %���ÿ��������������ڱ���Լ�����
    properties
        %ch_name operate_type ����Ϊ��չ�ຯ���ıر�Ҫ��
        name;
        ch = {};
        label = {};
        operate_type;
        instr = {};
        slope = 1;
        from = 0;
    end
        
    methods
        function obj = slope_scan(name,varargin)
            %instrument_parameter����ITEK
            obj.name = name;
            while isempty(varargin)
                obj.instr{length(instr)+1} = varargin{1};
                obj.ch{length(ch)+1} = varargin{2};
                varargin(1:2) = [];
            end
            obj.label = obj.instr{1}.label;
            obj.operate_type = obj.instr{1}.operate_type{obj.ch{1}};
        end
        
        %% �����ܺ���
        function out_put = operate(obj,~,~)
            out_put = @(value)obj.set(value);
        end
        function set(obj,value)
            obj.instr{1}.set(obj.ch{1},value);
            obj.instr{2}.set(obj.ch{2},obj.from+obj.slope*value);
        end
    end
end
