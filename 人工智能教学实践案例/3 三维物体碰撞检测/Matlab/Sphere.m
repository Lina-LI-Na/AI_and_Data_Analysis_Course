function bounding_sphere_demo()

    clc; clear; close all;

    % Simulation parameters
    move_speed = 0.1;
    dt = 1/240;

    % Sphere definitions
    sphere1.center = [0, 0, 1];
    sphere1.radius = 1.5;

    sphere2.center = [5, 5, 1];
    sphere2.radius = 1.0;

    % Create figure
    fig = figure('Name','Bounding Sphere Collision Simulation', ...
        'KeyPressFcn',@onKeyPress);
    axis equal;
    axis([-3 8 -3 8 0 3]);
    grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(45,30);
    hold on;
    disp('Use arrow keys to move the box. Press ESC to quit.');
    % Main simulation loop
    while ishandle(fig)
        clf;
        hold on;
        axis equal;
        axis([-3 8 -3 8 0 3]);
        xlabel('X'); ylabel('Y'); zlabel('Z');
        view(45,30);
        grid on;

        % Draw spheres
        drawSphere(sphere1,'b');
        drawSphere(sphere2,'r');

        % Check collision
        if isColliding(sphere1, sphere2)
            title('Collision detected!','Color','r','FontSize',14);
        else
            title('No collision','Color','b','FontSize',14);
        end
        drawnow
        pause(dt);
    end

    % -------- Nested function: handle keyboard ----------
    function onKeyPress(~, event)
        switch event.Key
            case 'leftarrow'
                sphere1.center(1) = sphere1.center(1) - move_speed;
            case 'rightarrow'
                sphere1.center(1) = sphere1.center(1) + move_speed;
            case 'uparrow'
                sphere1.center(2) = sphere1.center(2) + move_speed;
            case 'downarrow'
                sphere1.center(2) = sphere1.center(2) - move_speed;
            case 'escape'
                close(gcf);
        end
    end
end

%% -------- Helper functions -----------

function drawSphere(sphere, color)
    % 方法1: 检查sphere函数是否可用
    try
        % 尝试标准调用方式
        [X,Y,Z] = sphere(20); % 20x20 mesh
    catch
        % 如果失败，使用替代方法
        n = 20;
        theta = pi*(-n:2:n)/n;
        phi = (pi/2)*(-n:2:n)'/n;
        X = cos(phi)*cos(theta);
        Y = cos(phi)*sin(theta);
        Z = sin(phi)*ones(size(theta));
    end
    
    % 缩放和平移球体
    X = X * sphere.radius + sphere.center(1);
    Y = Y * sphere.radius + sphere.center(2);
    Z = Z * sphere.radius + sphere.center(3);
    
    % 绘制球体
    surf(X,Y,Z,'FaceColor',color,'EdgeColor','none','FaceAlpha',0.5);
end

function colliding = isColliding(s1, s2)
    distance = norm(s1.center - s2.center);
    colliding = distance < (s1.radius + s2.radius);
end