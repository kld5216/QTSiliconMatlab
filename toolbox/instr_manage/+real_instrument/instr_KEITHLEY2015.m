classdef instr_KEITHLEY2015<instrument.PKeithley2015
    %对外从操作的通一函数仅有生成函数和操作函数
    %完成每个操作句柄的类内编号以及命名
    properties
        %ch_name operate_type 三者为拓展类函数的必备要素
        num = 1;
        ch = {};
        label = {};
        operate_type = {};% 'read'/'set'/'both'/'ban' useless=ban
        step = {};
        delay = {};
    end
        
    methods
        function obj = instr_KEITHLEY2015(address,filepath)
            %instrument_parameter配置ITEK
            % 通过配置文件读取 e.g.:filepath = '.\Defaults_para\Defaults_setting\instr_para\ITEK.txt'
            obj = obj@instrument.PKeithley2015(address);
            fid = fopen(filepath);
%             disp(address);
            for i = 1:obj.num
                str = strsplit(fgetl(fid),' ');
                obj.ch{i} = str{1};
                obj.label{i} = str{2};
                obj.operate_type{i} = str{3};
            end          
        end
        
        %% 主功能函数
        function out_put = operate(obj,type,idx)
            %operate('read',idx);
            %operate('set',idx);
            obj.operate_check(type,idx);
            switch type
                case'read'
                    out_put = @()obj.read_current();
                case'set'
                    out_put = 0;
            end
        end
          %% 操作是否被禁用
        function operate_check(obj,type,idx)
            % right/wrong 1/0
            if ~(strcmp(type,'set')||strcmp(type,'read'))
                error('instr_KEITHLEY2015:operate_check',['type of ' obj.ch{idx} ' is wrong!']);
            end
            switch idx
                case {1,2}
                    switch obj.operate_type{idx}
                        case 'ban'
                            error('instr_KEITHLEY2015:operate_check',[obj.ch{idx},' is ban!']);
                        case 'both'
                        case 'read'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_KEITHLEY2015:operate_check',[obj.ch{idx},' is only read!']);
                            end
                        case 'set'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_KEITHLEY2015:operate_check',[obj.ch{idx},' is only set!']);
                            end
                        otherwise
                            error('instr_KEITHLEY2015:operate_check',[obj.ch{idx},' opreate type in ITEK.txt is illegal! ',obj.operate_type{idx}]);
                    end
                otherwise
                    error('instr_KEITHLEY2015:operate_check',['index ' num2str(idx) ' out of range!']);
            end
        end       
    end
end

