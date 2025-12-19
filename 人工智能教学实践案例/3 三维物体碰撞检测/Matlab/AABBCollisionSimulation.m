function AABBCollisionSimulation
clear; clc; close all;

% ---------- AABB 结构 ----------
AABB = @(minPoint, maxPoint) struct( ...
    'minX', minPoint(1), 'minY', minPoint(2), 'minZ', minPoint(3), ...
    'maxX', maxPoint(1), 'maxY', maxPoint(2), 'maxZ', maxPoint(3));

% ---------- 3D AABB 碰撞 ----------
isColliding = @(A, B) ...
    (A.minX <= B.maxX && A.maxX >= B.minX) && ...
    (A.minY <= B.maxY && A.maxY >= B.minY) && ...
    (A.minZ <= B.maxZ && A.maxZ >= B.minZ);

% ---------------- 绘图设置 ----------------
figure('Name','3D AABB Collision Simulation', ...
       'Color','white','KeyPressFcn',@keyDownListener);

axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(45,25); hold on;

% ---------- Box + Sphere 参数 ----------
box_size = [1, 1, 1.5];
sphere_radius = 1.0;

box_pos = [0,0,1];
sphere_pos = [5,5,1];

% ---------- 绘制 Box ----------
[box_vertices, box_faces] = createBox(box_pos, box_size);

box_patch = patch('Vertices', box_vertices, ...
                  'Faces', box_faces, ...
                  'FaceColor','b','FaceAlpha',0.4,'EdgeColor','none');

% ---------- 绘制球 ----------
[sX, sY, sZ] = sphere(30);
surf(sX*sphere_radius + sphere_pos(1), ...
     sY*sphere_radius + sphere_pos(2), ...
     sZ*sphere_radius + sphere_pos(3), ...
     'FaceColor','r','FaceAlpha',0.4,'EdgeColor','none');

% ---------- 运动控制 ----------
move_speed = 0.1;
global moveDir;
moveDir = [0 0 0];

disp('Use arrow keys to move the box. Press ESC to quit.');

% ---------------- 主循环 ----------------
while ishandle(box_patch)

    % 更新位置
    box_pos = box_pos + moveDir * move_speed;

    % 构建 AABB
    A_box = AABB(box_pos - box_size/2, box_pos + box_size/2);
    A_sphere = AABB(sphere_pos - sphere_radius, sphere_pos + sphere_radius);

    % 碰撞检测
    if isColliding(A_box, A_sphere)
        title('⚠ Collision Detected','Color','r');
    else
        title('No Collision','Color','k');
    end

    % 更新 box 顶点
    box_patch.Vertices = createBoxVertices(box_pos, box_size);

    drawnow;
    pause(0.02);
end

disp('Simulation ended.');
end

function [V, F] = createBox(center, sz)
    V = createBoxVertices(center, sz);
    F = [
        1 2 4 3;
        5 6 8 7;
        1 2 6 5;
        2 4 8 6;
        4 3 7 8;
        3 1 5 7
    ];
end

function V = createBoxVertices(center, sz)
    dx = sz(1)/2; dy = sz(2)/2; dz = sz(3)/2;
    V = [
        center + [-dx -dy -dz];
        center + [ dx -dy -dz];
        center + [-dx  dy -dz];
        center + [ dx  dy -dz];
        center + [-dx -dy  dz];
        center + [ dx -dy  dz];
        center + [-dx  dy  dz];
        center + [ dx  dy  dz]
    ];
end


function keyDownListener(~, event)
    global moveDir;
    switch event.Key
        case 'leftarrow'
            moveDir = [-1 0 0];
        case 'rightarrow'
            moveDir = [1 0 0];
        case 'uparrow'
            moveDir = [0 1 0];
        case 'downarrow'
            moveDir = [0 -1 0];
        case 'escape'
            close(gcf);
        otherwise
            moveDir = [0 0 0];
    end
end
