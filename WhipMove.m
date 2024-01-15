classdef WhipMove
    properties
        length
        rigidity
        num_point
        num_time_steps
        mass_array
        amplitude
        gravity
    end

    methods
        function obj = WhipMove(rigidity, num_point, amplitude, gravity)
            if nargin < 4
                obj.amplitude = 5;
            else
                obj.amplitude = amplitude;
            end
            if nargin < 3
                obj.gravity = true;
            else
                obj.gravity = gravity;
            end
            if nargin < 2
                obj.rigidity = 10;
            else
                obj.rigidity = rigidity;
            end
            if nargin < 1
                obj.num_point = 15;
            else
                obj.num_point = num_point;
            end
            
            initial_mass = 5;
            obj.mass_array = initial_mass * exp(-linspace(0, 1, obj.num_point));
            obj.mass_array = obj.mass_array / sum(obj.mass_array);
        end

        function vizual(obj)
            g = 9.8;
            tau = 2 * pi * sqrt(sum(obj.mass_array) / obj.rigidity);
            obj.length = 1;
            a = obj.length / obj.num_point;

            x = linspace(0, obj.length, obj.num_point) 
            x(1) = 0;
            y = zeros(1, obj.num_point) 
            y(1) = 0;

            vel_x = zeros(1, obj.num_point) / obj.length * tau;
            vel_x(1) = 0;
            vel_y = zeros(1, obj.num_point) / obj.length * tau;
            vel_y(1) = 0;

            F_x = zeros(1, obj.num_point - 1);
            F_y = zeros(1, obj.num_point - 1);
            
            obj.num_time_steps = 5000;
            time = linspace(0, 5 * tau, obj.num_time_steps) / tau;
            dt = time(2) - time(1);

            if obj.gravity
                force_g = (obj.mass_array * g) / (obj.rigidity * obj.length);
            else
                force_g = zeros(1, obj.num_point);
            end
            
            % Настройка анимации
            figure;
            scatterHandle = scatter(x, y, 'filled', 'k');
            xlabel('Ось X');
            ylabel('Ось Y');
            axis([-0.5 1.5 -10 10]);
            grid on;
            hold on;
            
            sign = 1;
            change = 100;
            for i = 1:obj.num_time_steps
                dx = x(2) - x(1);
                dy = y(2) - y(1);
                h = sqrt(dx ^ 2 + dy ^ 2);
                F_x(1) = (h - a) * dx / h;
                F_y(1) = (h - a) * dy / h;

                if i == change
                    vel_y(1) = sign * obj.amplitude*(1+rand);
                    sign = sign * (-1);
                    change = change + 500;
                end

                for j = 2:obj.num_point - 1
                    dx = x(j + 1) - x(j);
                    dy = y(j + 1) - y(j);
                    h = sqrt(dx ^ 2 + dy ^ 2);

                    F_x(j) = (h - a) * dx / h;
                    F_y(j) = (h - a) * dy / h;

                    vel_x(j) = vel_x(j) + (F_x(j) - F_x(j - 1)) * dt * (4 * pi ^ 2);
                    vel_y(j) = vel_y(j) + (F_y(j) - F_y(j - 1) - force_g(j)) * dt * (4 * pi ^ 2);
                end

                vel_x(obj.num_point) = vel_x(obj.num_point) + (-F_x(obj.num_point - 1)) * dt * (4 * pi ^ 2);
                vel_y(obj.num_point) = vel_y(obj.num_point) + (-F_y(obj.num_point - 1) - force_g(obj.num_point)) * dt * (4 * pi ^ 2);

                for j = 1:obj.num_point
                    x(j) = x(j) + vel_x(j) * dt;
                    y(j) = y(j) + vel_y(j) * dt;
                end
                if mod(i, 10) == 0
                    if isvalid(scatterHandle)
        % Проверка, существует ли объект графика и не удален ли он
                        scatterHandle.XData = x;
                        scatterHandle.YData = y;
                        drawnow;
                    else
        % Если объект графика удален, завершаем цикл
                        return;
                    end
                end
            end
        end
    end
end
