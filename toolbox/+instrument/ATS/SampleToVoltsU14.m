function [ sampleVoltsList ] = SampleToVoltsU14( sampleValueList , inputRange_volts )
%SAMPLETOVOLTSU12 此处显示有关此函数的摘要
%   此处显示详细说明
    sampleValueList = bitshift(sampleValueList,-2);
    sampleValueList = double(sampleValueList);
    sampleVoltsList = (sampleValueList-8191.5)/8191.5 * inputRange_volts;
end

