classdef instr_SR830<instrument.PSR830
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %ch_name operate_type 三者为拓展类函数的必备要素
        ch={};
        ch_name={};
        operate_type={};% 'read'/'set'/'both'/'ban' useless=ban

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
            % 通过配置文件读取 e.g.:filepath = '.\Defaults_para\Defaults_setting\instrument_parameter\SR830.txt'
            obj = obj@instrument.PSR830(address);
            fid = fopen(filepath);
            for i = 1:11
                str = strsplit(fgetl(fid),' ');
                obj.ch{i} = str{1};
                obj.ch_name{i} = str{2};
                obj.operate_type{i} = str{3};
            end
            try
                obj.stepAux = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
                obj.delayAux = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
                obj.stepAmp = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
                obj.delayAmp = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
                obj.stepFreq = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
                obj.delayFreq = str2double(regexp(fgetl(fd),'\d*\.?\d*','match','once'));
            catch exception
                error(exception.identifier,exception.message);
            end
        end
        
        %% 主功能函数
        function out_put= operate(obj,type,idx,varargin)
            %operate('read',idx);
            %operate('set',idx,value,('direct'/'step','delay'));
            obj.operate_check(type,idx);
            if strcmp(type,'read')
                out_put = obj.SR830_read(idx);
            end
            if strcmp(type,'set')
                if ~isempty(varargin)
                    out_put = obj.SR830_set(idx,varargin{:});
                else
                    error('instr_SR830:operate','number of set parameters not enough!');
                end
            end
        end
          %% 操作是否被禁用
        function operate_check(obj,type,idx)
            % right/wrong 1/0
            if ~(strcmp(type,'set')||strcmp(type,'read'))
                error('instr_SR830:operate_check',['type of ' obj.ch{idx} ' is wrong!']);
            end
            switch idx
                case {1:11}
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
        %% 功能函数（基于SR830）
        function out_put=SR830_read(obj,idx)
            switch idx
                case 1 %I_x(read only)
                    out_put=obj.read_current(1);
                case 2 %I_y(read only)
                    out_put=obj.read_current(2);
                case 3 %Lockin_I(read only)
                    out_put=obj.read_current(3);
                case 4 %Lockin_Theta(read only)
                    out_put=obj.read_current(4);
                case 5 %Aux1
                    out_put=obj.read_aux(1);
                case 6 %Aux2
                    out_put=obj.read_aux(2);
                case 7 %Aux3
                    out_put=obj.read_aux(3);
                case 8 %Aux4
                    out_put=obj.read_aux(4);
                case 9 %Lockin_Freq
                    out_put=obj.read_freq(0);
                case 10 %Lockin_Amp
                    out_put=obj.read_amp(0);
                case 11 %sens
                    out_put=obj.read_sens(0);
            end
        end
        
        function SR830_set(obj,idx,varargin)
            % varargin='direct'
            %          无'direct'则可以设置：'step',默认step|大于0的浮点数/'delay',默认delay|大于0的浮点数
            
            %用于实现直接设置功能
            while ~isempty(varargin)
                switch varargin{1}
                    case 'direct'
                        obj.subset(idx,value);
                        break;
                    case 'step'
                        if isempty(varargin{2})
                            error('instr_SR830:SR830_set','lack of index');
                        end
                        change_step = varargin{2};
                        
                end
            end
%             else
%                 str_error='wrong instr_SR830 operate ?direct?num?idx? !';
%                 errordlg(str_error,'SR830_Error');
            
            if length(varargin) >= 3 && ~varargin{3}
                change_step = varargin{3};
            else
                change_step =  0;
            end
            if length(varargin) >= 4 && ~varargin{4}
                change_delay = varargin{4};
            else
                change_delay=0.1;
            end
            %% 更改电压
            Now_value=obj.SR830_read(idx);
            if (Now_value~=value)
                %                 obj.cheak_value(idx,value);
                change_step=abs(change_step);
                if (Now_value>value)
                    change_step=-change_step;
                end
                for i=Now_value:change_step:value
                    obj.subset(idx,i);
                    pause(change_delay);
                end
                obj.subset(idx,value);
            end
            out_put=1;
        end
        
        function subset(obj,idx,value)
            switch idx
                case 1 %I_x(read only)
                case 2 %I_y(read only)
                case 3 %Lockin_I(read only)
                case 4 %Lockin_Theta(read only)
                case 5 %Aux1
                    obj.write_aux(1,value);
                case 6 %Aux2
                    obj.write_aux(2,value);
                case 7 %Aux3
                    obj.write_aux(3,value);
                case 8 %Aux4
                    obj.write_aux(4,value);
                case 9 %Lockin_Freq
                    obj.write_freq(value);
                case 10 %Lockin_Amp
                    obj.write_amp(value);
                case 11 %sens
                    obj.write_sens(value);
            end
        end
      
    end
end

