classdef instr_A33522A<instrument.Pa33522a
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %ch_name operate_type 三者为拓展类函数的必备要素
        name;
        num = 6;
        ch = {};
        label = {};
        operate_type = {};% 'read'/'set'/'both'/'ban' useless=ban
        step = {};
        delay = {};
        SquareFreqStep=100;
        SquareFreqDelay=0.2;
        SquareAmpStep=0.005;
        SquareAmpDelay=0.3;
        SquarePerStep=0.1;
        SquarePerDelay=0.3;
    end
        
    methods
        function obj = instr_A33522A(name,address,filepath)
            %instrument_parameter配置SR830
            % 通过配置文件读取 e.g.:filepath = '.\Defaults_para\Defaults_setting\instr_para\SR830.txt'
            obj = obj@instrument.Pa33522a(address);
            obj.name = name;
            fid = fopen(filepath);
%             disp(address);
            for i = 1:obj.num
                str = strsplit(fgetl(fid),' ');
                obj.ch{i} = str{1};
                obj.label{i} = str{2};
                obj.operate_type{i} = str{3};
            end
            try
                obj.SquareFreqStep = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.SquareFreqDelay = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.SquareAmpStep = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.SquareAmpDelay = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.SquarePerStep = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.SquarePerDelay = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
            catch exception
                warning(exception.identifier,'%s',exception.message);
            end
            obj.step = {obj.SquareFreqStep,obj.SquareAmpStep,obj.SquarePerStep,obj.SquareFreqStep,obj.SquareAmpStep,obj.SquarePerSteps};
            obj.delay = {obj.SquareFreqDelay,obj.SquareAmpDelay,obj.SquarePerDelay,obj.SquareFreqDelay,obj.SquareAmpDelay,obj.SquarePerDelay};
        end
        
        %% 主功能函数
        function out_put = operate(obj,type,idx)
            %operate('read',idx);
            %operate('set',idx);
            obj.operate_check(type,idx);
            switch type
                case'read'
                    out_put = @()obj.read(idx);
                case'set'
                    out_put = @(value)obj.set(idx,value);
            end
        end
          %% 操作是否被禁用
        function operate_check(obj,type,idx)
            % right/wrong 1/0
            if ~(strcmp(type,'set')||strcmp(type,'read'))
                error('instr_A33522A:operate_check',['type of ' obj.ch{idx} ' is wrong!']);
            end
            switch idx
                case {1,2,3,4,5,6}
                    switch obj.operate_type{idx}
                        case 'ban'
                            error('instr_A33522A:operate_check',[obj.ch{idx},' is ban!']);
                        case 'both'
                        case 'read'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_A33522A:operate_check',[obj.ch{idx},' is only read!']);
                            end
                        case 'set'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_A33522A:operate_check',[obj.ch{idx},' is only set!']);
                            end
                        otherwise
                            error('instr_A33522A:operate_check',[obj.ch{idx},' opreate type in SR830.txt is illegal! ',obj.operate_type{idx}]);
                    end
                otherwise
                    error('instr_A33522A:operate_check',['index ' num2str(idx) ' out of range!']);
            end
        end
        %% 功能函数（基于SR830）取得函数句柄
        function out_put = read(obj,idx)
            switch idx
                case 1 
                    out_put = obj.read_freq(1);
                case 2 
                    out_put = obj.read_amp(1);
                case 3 
                    out_put = obj.read_period(1);
                case 4 
                    out_put = obj.read_freq(2);
                case 5 
                    out_put = obj.read_amp(2);
                case 6 
                    out_put = obj.read_period(2);                
            end
        end
        
        function set(obj,idx,value)
            switch idx
                case 1
                    obj.set_freq(1,value);
                case 2 
                    obj.set_amp(1,value);
                case 3 
                    obj.set_period(1,value);
                case 4 
                    obj.set_freq(2,value);
                case 5
                    obj.set_amp(2,value);
                case 6
                    obj.set_period(2,value);
            end
        end
        %% 缓变设置
        function set_slow(obj,idx,varargin)
            % varargin='direct'
            %          无'direct'则可以设置：'step',默认step|大于0的浮点数/'delay',默认delay|大于0的浮点数
            %% 检索varargin合法性
            while ~isempty(varargin)
                switch varargin{1}
                    case 'direct'
                        obj.set(idx,value);
                        break;
                    case 'step'
                        if isempty(varargin{2})
                            error('instr_A33522A:set_slow','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_A33522A:set_slow','step应为大于0的浮点数');
                        end
                        obj.step{idx} = varargin{2};
                        varargin(1:2) = [];
                    case 'delay'
                        if isempty(varargin{2})
                            error('instr_A33522A:set_slow','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_A33522A:set_slow','delay应为大于0的浮点数');
                        end
                        obj.delay{idx} = varargin{2};
                        varargin(1:2) = [];
                end
            end
            %% 更改电压
            Step = obj.step{idx};
            Delay = obj.delay{idx};
            Now_value = obj.read(idx);
            if Now_value ~= value
                Step = abs(Step);
                if Now_value > value
                    Step = -Step;
                end
                for i = Now_value:Step:value
                    obj.set(idx,i);
                    pause(Delay);
                end
                obj.set(idx,value);
            end
        end        
    end
end

