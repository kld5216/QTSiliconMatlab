function [ sampleVoltsList ] = SampleToVoltsU14( sampleValueList , inputRange_volts )
%SAMPLETOVOLTSU12 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    sampleValueList = bitshift(sampleValueList,-2);
    sampleValueList = double(sampleValueList);
    sampleVoltsList = (sampleValueList-8191.5)/8191.5 * inputRange_volts;
end

