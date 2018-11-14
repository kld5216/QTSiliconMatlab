sRate = 100e3;
name = 'T1test';
amp = 0.04;
totaltime = 0.02;
IP = '192.168.1.116';

point{1} = [0, 0];
point{2} = [0.005, 0.04];
point{3} = [0.010, 0.02];
point{4} = [0.015, 0];
point{5} = [totaltime, 0];

totalpoints = sRate * totaltime;

arb = zeros(1,totalpoints);
for j = 1:4
    for i = sRate * point{j}(1) + 1:sRate * point{j+1}(1)
        arb(i) = point{j}(2);
    end
end

arbTo33500(arb,IP,amp,sRate,name);