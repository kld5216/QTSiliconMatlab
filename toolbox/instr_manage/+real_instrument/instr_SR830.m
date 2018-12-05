classdef instr_SR830<instrument.PSR830
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %ch_name operate_type 三者为拓展类函数的必备要素
        num = 11;
        ch = {};
        label = {};
        operate_type = {};% 'read'/'set'/'both'/'ban' useless=ban
        step = {};
        delay = {};
        stepAux = 0.03;
        delayAux = 0.05;
        stepAmp = 0.02;
        delayAmp = 0.03;
        stepFreq = 10;
        delayFreq = 0.03;
    end
        
    methods
        function obj = instr_SR830(address,filepath)
            %instrument_parameter配置SR830
            % 通过配置文件读取 e.g.:filepath = '.\Defaults_para\Defaults_setting\instr_para\SR830.txt'
            obj = obj@instrument.PSR830(address);
            fid = fopen(filepath);
%             disp(address);
            for i = 1:obj.num
                str = strsplit(fgetl(fid),' ');
                obj.ch{i} = str{1};
                obj.label{i} = str{2};
                obj.operate_type{i} = str{3};
            end
            try
                obj.stepAux = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.delayAux = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.stepAmp = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.delayAmp = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.stepFreq = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
                obj.delayFreq = str2double(regexp(fgetl(fid),'\d*\.?\d*','match','once'));
            catch exception
                warning(exception.identifier,'%s',exception.message);
            end
            obj.step = {0,0,0,0,...
                obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,...
                obj.stepAmp,...
                obj.stepFreq};
            obj.delay = {0,0,0,0,...
                obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,...
                obj.delayAmp,...
                obj.delayFreq};
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
                error('instr_SR830:operate_check',['type of ' obj.ch{idx} ' is wrong!']);
            end
            switch idx
                case {1,2,3,4,5,6,7,8,9,10,11}
                    switch obj.operate_type{idx}
                        case 'ban'
                            error('instr_SR830:operate_check',[obj.ch{idx},' is ban!']);
                        case 'both'
                        case 'read'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_SR830:operate_check',[obj.ch{idx},' is only read!']);
                            end
                        case 'set'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_SR830:operate_check',[obj.ch{idx},' is only set!']);
                            end
                        otherwise
                            error('instr_SR830:operate_check',[obj.ch{idx},' opreate type in SR830.txt is illegal! ',obj.operate_type{idx}]);
                    end
                otherwise
                    error('instr_SR830:operate_check',['index ' num2str(idx) ' out of range!']);
            end
        end
        %% 功能函数（基于SR830）取得函数句柄
        function out_put = read(obj,idx)
            switch idx
                case 1 %I_x(read only)
                    out_put = obj.read_current(1);
                case 2 %I_y(read only)
                    out_put = obj.read_current(2);
                case 3 %Lockin_I(read only)
                    out_put = obj.read_current(3);
                case 4 %Lockin_Theta(read only)
                    out_put = obj.read_current(4);
                case 5 %Aux1
                    out_put = obj.read_aux(1);
                case 6 %Aux2
                    out_put = obj.read_aux(2);
                case 7 %Aux3
                    out_put = obj.read_aux(3);
                case 8 %Aux4
                    out_put = obj.read_aux(4);
                case 9 %Lockin_Freq
                    out_put = obj.read_freq(0);
                case 10 %Lockin_Amp
                    out_put = obj.read_amp(0);
                case 11 %sens
                    out_put = obj.read_sens(0);
            end
        end
        
        function set(obj,idx,value)
            switch idx
                case 1 %I_x(read only)
                case 2 %I_y(read only)
                case 3 %Lockin_I(read only)
                case 4 %Lockin_Theta(read only)
                case 5 %Aux1
                    obj.set_aux(1,value);
                case 6 %Aux2
                    obj.set_aux(2,value);
                case 7 %Aux3
                    obj.set_aux(3,value);
                case 8 %Aux4
                    obj.set_aux(4,value);
                case 9 %Lockin_Freq
                    obj.set_freq(0,value);
                case 10 %Lockin_Amp
                    obj.write_amp(0,value);
                case 11 %sens
                    obj.write_sens(0,value);
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
                            error('instr_SR830:SR830_set','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_SR830:SR830_set','step应为大于0的浮点数');
                        end
                        obj.step{idx} = varargin{2};
                        varargin(1:2) = [];
                    case 'delay'
                        if isempty(varargin{2})
                            error('instr_SR830:SR830_set','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_SR830:SR830_set','delay应为大于0的浮点数');
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

