+function [ sampleVoltsList ] = SampleToVoltsU12( sampleValueList , inputRange_volts )
%SAMPLETOVOLTSU12 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    sampleValueList = bitshift(sampleValueList,-4);
    sampleValueList = double(sampleValueList);
    sampleVoltsList = (sampleValueList-2047.5)/2047.5 * inputRange_volts;
end

