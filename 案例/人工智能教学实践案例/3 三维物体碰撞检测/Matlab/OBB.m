function obb_collision_demo()

    clc; clear; close all;

    move_speed = 0.05;
    dt = 1/120;

    % Box 1
    box1.center = [0, 0, 1];
    box1.half = [0.5, 0.8, 0.5];
    box1.rotation = eye(3);   % No rotation

    % Box 2
    box2.center = [2, 2, 1];
    box2.half = [0.6, 0.4, 0.5];
    box2.rotation = eul2rotm([0.2, 0.3, 0.5]);   % Add some rotation

    fig = figure('Name','OBB Collision','KeyPressFcn',@onKeyPress);
    axis equal; grid on;
    axis([-3 3 -3 3 0 3]);
    view(45,30);
    hold on;
    disp('Use arrow keys to move the box. Press "q" and "w" for rotation, Press ESC to quit.');
    while ishandle(fig)
        cla; hold on;
        axis([-3 3 -3 3 0 3]);
        view(45,30);
        grid on; xlabel X; ylabel Y; zlabel Z;

        drawOBB(box1,'b');
        drawOBB(box2,'r');

        if OBBvsOBB(box1, box2)
            title('⚠️ Collision Detected','Color','r','FontSize',14);
        else
            title('No Collision','Color','b','FontSize',14);
        end
        drawnow
        pause(dt);
    end

    function onKeyPress(~, event)
        switch event.Key
            case 'leftarrow'
                box1.center(1) = box1.center(1) - move_speed;
            case 'rightarrow'
                box1.center(1) = box1.center(1) + move_speed;
            case 'uparrow'
                box1.center(2) = box1.center(2) + move_speed;
            case 'downarrow'
                box1.center(2) = box1.center(2) - move_speed;
            case 'q'
                box1.rotation = axang2rotm([0 0 1 0.05]) * box1.rotation;
            case 'w'
                box1.rotation = axang2rotm([0 1 0 0.05]) * box1.rotation;
            case 'escape'
                close(gcf);
        end
    end
end

%% ========== SUPPORT FUNCTIONS ==========

function drawOBB(obb, col)
    C = getCorners(obb);
    K = convhull(C(:,1),C(:,2),C(:,3));
    trisurf(K, C(:,1),C(:,2),C(:,3), 'FaceAlpha',0.2, ...
        'EdgeColor',col, 'FaceColor',col);
end

function C = getCorners(obb)
    R = obb.rotation;
    h = obb.half;
    c = obb.center;

    axisX = R(:,1) * h(1);
    axisY = R(:,2) * h(2);
    axisZ = R(:,3) * h(3);

    C = zeros(8,3);
    idx = 1;
    for i = [-1 1]
        for j = [-1 1]
            for k = [-1 1]
                C(idx,:) = c + i*axisX' + j*axisY' + k*axisZ';
                idx = idx + 1;
            end
        end
    end
end

%% -------- SAT for OBB vs OBB (15 axes) --------
function coll = OBBvsOBB(A, B)

    RA = A.rotation;
    RB = B.rotation;

    axesA = [RA(:,1), RA(:,2), RA(:,3)];
    axesB = [RB(:,1), RB(:,2), RB(:,3)];

    % --- 1) 3 axes from box A
    for i=1:3
        if isSeparated(A,B,axesA(:,i)), coll=false; return; end
    end

    % --- 2) 3 axes from box B
    for i=1:3
        if isSeparated(A,B,axesB(:,i)), coll=false; return; end
    end

    % --- 3) 9 cross product axes (Ai × Bj)
    for i=1:3
        for j=1:3
            axis = cross(axesA(:,i), axesB(:,j));
            if norm(axis) < 1e-8
                continue;  % parallel axes -> ignore
            end
            axis = axis / norm(axis);
            if isSeparated(A,B,axis), coll=false; return; end
        end
    end

    coll = true; % no separation
end

function sep = isSeparated(A, B, axis)
    [minA,maxA] = projectBox(A, axis);
    [minB,maxB] = projectBox(B, axis);
    sep = (maxA < minB) || (maxB < minA);
end

function [mn, mx] = projectBox(obb, axis)
    C = getCorners(obb);
    proj = C * axis;
    mn = min(proj);
    mx = max(proj);
end
