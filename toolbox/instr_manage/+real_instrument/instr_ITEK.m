classdef instr_ITEK<instrument.PItek
    %����Ӳ�����ͨһ�����������ɺ����Ͳ�������
    %���ÿ��������������ڱ���Լ�����
    properties
        %ch_name operate_type ����Ϊ��չ�ຯ���ıر�Ҫ��
        num = 16;
        ch = {};
        label = {};
        operate_type = {};% 'read'/'set'/'both'/'ban' useless=ban
        step = {};
        delay = {};
        stepAux = 0.03;
        delayAux = 0.05;
    end
        
    methods
        function obj = instr_ITEK(address,filepath)
            %instrument_parameter����ITEK
            % ͨ�������ļ���ȡ e.g.:filepath = '.\Defaults_para\Defaults_setting\instr_para\ITEK.txt'
            obj = obj@instrument.PItek(address);
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
            catch exception
                warning(exception.identifier,'%s',exception.message);
            end
            obj.step = {obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,...
                obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux,obj.stepAux};
            obj.delay = {obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,...
                obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux,obj.delayAux};
        end
        
        %% �����ܺ���
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
          %% �����Ƿ񱻽���
        function operate_check(obj,type,idx)
            % right/wrong 1/0
            if ~(strcmp(type,'set')||strcmp(type,'read'))
                error('instr_ITEK:operate_check',['type of ' obj.ch{idx} ' is wrong!']);
            end
            switch idx
                case {1,2,3,4,5,6,7,8,9,10,11}
                    switch obj.operate_type{idx}
                        case 'ban'
                            error('instr_ITEK:operate_check',[obj.ch{idx},' is ban!']);
                        case 'both'
                        case 'read'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_ITEK:operate_check',[obj.ch{idx},' is only read!']);
                            end
                        case 'set'
                            if ~strcmp(type,obj.operate_type{idx})
                                error('instr_ITEK:operate_check',[obj.ch{idx},' is only set!']);
                            end
                        otherwise
                            error('instr_ITEK:operate_check',[obj.ch{idx},' opreate type in ITEK.txt is illegal! ',obj.operate_type{idx}]);
                    end
                otherwise
                    error('instr_ITEK:operate_check',['index ' num2str(idx) ' out of range!']);
            end
        end
        %% ���ܺ���������ITEK��ȡ�ú������
        function out_put = read(obj,idx)
            out_put = obj.read_volt(idx);
        end
        
        function set(obj,idx,value)
            obj.set_volt(idx,value);
        end
        %% ��������
        function set_slow(obj,idx,varargin)
            % varargin='direct'
            %          ��'direct'��������ã�'step',Ĭ��step|����0�ĸ�����/'delay',Ĭ��delay|����0�ĸ�����
            %% ����varargin�Ϸ���
            while ~isempty(varargin)
                switch varargin{1}
                    case 'direct'
                        obj.set(idx,value);
                        break;
                    case 'step'
                        if isempty(varargin{2})
                            error('instr_ITEK:set_slow','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_ITEK:set_slow','stepӦΪ����0�ĸ�����');
                        end
                        obj.step{idx} = varargin{2};
                        varargin(1:2) = [];
                    case 'delay'
                        if isempty(varargin{2})
                            error('instr_ITEK:set_slow','lack of index');
                        elseif ~isfloat(varargin{2})||varargin{2} <= 0
                            error('instr_ITEK:set_slow','delayӦΪ����0�ĸ�����');
                        end
                        obj.delay{idx} = varargin{2};
                        varargin(1:2) = [];
                end
            end
            %% ���ĵ�ѹ
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

