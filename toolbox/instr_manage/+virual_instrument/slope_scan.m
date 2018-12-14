classdef slope_scan<handle
    %����Ӳ�����ͨһ�����������ɺ����Ͳ�������
    %���ÿ��������������ڱ���Լ�����
    properties
        %name ch label operate_type Ϊ��չ�ຯ���ıر�Ҫ��
        name;
        ch = {};
        label = {};
        operate_type;
        %����Ϊ�������
        instr = {};
        channel = {};
        step = {};
        delay = {};
        slope = 1;
        from = 0;
    end
        
    methods
        function obj = slope_scan(name,varargin)
            %instrument_parameter����ITEK
            obj.name = name;
            while ~isempty(varargin)
                obj.instr{length(obj.instr)+1} = varargin{1};
                obj.channel{length(obj.channel)+1} = varargin{2};
                varargin(1:2) = [];
            end
            obj.ch = obj.instr{1}.ch(obj.channel{1});
            obj.label = obj.instr{1}.label(obj.channel{1});
            obj.operate_type = obj.instr{1}.operate_type(obj.channel{1});
            obj.step = obj.instr{1}.step(obj.channel{1});
            obj.delay = obj.instr{1}.delay(obj.channel{1});
        end
        
        %% �����ܺ���
        function out_put = operate(obj,type,~)
            switch type
                case 'set'
                    out_put = @(value)obj.set(value);
                case 'read'
                    out_put = @()obj.instr{1}.read(obj.channel{1});
            end
        end
        function set(obj,value)
            obj.instr{1}.set(obj.channel{1},value);
            pause(obj.delay{1});
            obj.instr{2}.set(obj.channel{2},obj.from+obj.slope*value);
        end
    end
end

