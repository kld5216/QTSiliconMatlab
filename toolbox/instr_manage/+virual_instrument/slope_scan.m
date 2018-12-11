classdef slope_scan<handle
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %name ch label operate_type 为拓展类函数的必备要素
        name;
        ch = {};
        label = {};
        operate_type;
        %以下为局域变量
        instr = {};
        channel = {};
        slope = 1;
        from = 0;
    end
        
    methods
        function obj = slope_scan(name,varargin)
            %instrument_parameter配置ITEK
            obj.name = name;
            while ~isempty(varargin)
                obj.instr{length(obj.instr)+1} = varargin{1};
                obj.channel{length(obj.channel)+1} = varargin{2};
                varargin(1:2) = [];
            end
            obj.ch = obj.instr{1}.ch(obj.channel{1});
            obj.label = obj.instr{1}.label(obj.channel{1});
            obj.operate_type = obj.instr{1}.operate_type(obj.channel{1});
        end
        
        %% 主功能函数
        function out_put = operate(obj,~,~)
            out_put = @(value)obj.set(value);
        end
        function set(obj,value)
            obj.instr{1}.set(obj.ch{1},value);
            obj.instr{2}.set(obj.ch{2},obj.from+obj.slope*value);
        end
    end
end

