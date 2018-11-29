function set_rfield(ips,th,R,n) %R初始磁场，n转轴方向，th旋转角度
            Rmtx = rotation(n,th);
            R = R * Rmtx;
            z=ips.read_field_z();
            y=ips.read_field_y();
            x=ips.read_field_x();
            [az,el,r] = cart2sph(x,y,z);
            fprintf(1,'target: %g %g %g\n',R(1),R(2),R(3));
            pause(1);
            
            
            t = 0;
            while(abs(z-R(3)) >= 0.2)
                if t < 1 || t > 10
                    ips.set_target_field_z(R(3));%增加磁场
                    pause(0.1);
                    ips.to_set_point_z();
                    t = 0;
                end
                z=ips.read_field_z();
                [az,el,r] = cart2sph(x,y,z);
                fprintf(1,'B_z = %gmT,fi = %g, theta = %g, r = %g\n',z,az*180/pi,90-el*180/pi,r);
                pause(1);
                t = t + 1;
            end
            pause(0.1);
            
            
            y=ips.read_field_y();
            t = 0;
            while(abs(y-R(2)) >= 0.2)
                if t < 1 || t > 10
                    ips.set_target_field_y(R(2));%增加磁场
                    pause(0.1);
                    ips.to_set_point_y();
                    t = 0;
                end
                y=ips.read_field_y();
                [az,el,r] = cart2sph(x,y,z);
                fprintf(1,'B_y = %gmT,fi = %g, theta = %g, r = %g\n',y,az*180/pi,90-el*180/pi,r);
                pause(1);
            end
            pause(0.5);
            
            x=ips.read_field_x();
            t = 0;
            while(abs(x-R(1)) >= 0.2)
                if t < 1 || t > 20
                    ips.set_target_field_x(R(1));%增加磁场
                    pause(0.1);
                    ips.to_set_point_x();
                    t = 0;
                end
                x=ips.read_field_x();
                [az,el,r] = cart2sph(x,y,z);
                fprintf(1,'B_x = %gmT,fi = %g, theta = %g, r = %g\n',x,az*180/pi,90-el*180/pi,r);
                pause(1);
            end
            pause(1);
        end