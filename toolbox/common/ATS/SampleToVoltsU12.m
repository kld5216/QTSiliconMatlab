+function [ sampleVoltsList ] = SampleToVoltsU12( sampleValueList , inputRange_volts )
%SAMPLETOVOLTSU12 此处显示有关此函数的摘要
%   此处显示详细说明
    sampleValueList = bitshift(sampleValueList,-4);
    sampleValueList = double(sampleValueList);
    sampleVoltsList = (sampleValueList-2047.5)/2047.5 * inputRange_volts;
end

