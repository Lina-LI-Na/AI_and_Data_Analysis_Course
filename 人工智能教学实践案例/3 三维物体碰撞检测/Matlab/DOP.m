function dop_collision_sim()
% DOP_COLLISION_SIM  - simple DOP/K-DOP collision demo (sphere vs ellipsoid)
% Save this file as dop_collision_sim.m and run: dop_collision_sim

clear; clc; close all;

% ========== PARAMETERS ==========
move_speed = 0.1;    % movement speed per step
fps = 60;
dt = 1/fps;
num_points = 40;     % sampling resolution for surfaces

sphere_pos = [0, 0, 1];
ellipsoid_pos = [5, 0, 1];

sphere_radius = 1.0;
ellipsoid_radii = [1.5, 1.0, 0.6];

% Example direction sets:
% 6-DOP (axis aligned)
dirs6 = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];

% 18-DOP (axes + diagonals) — higher accuracy
dirs18 = [
    1 0 0; -1 0 0;
    0 1 0; 0 -1 0;
    0 0 1; 0 0 -1;
    1 1 0; -1 -1 0;
    1 -1 0; -1 1 0;
    1 0 1; -1 0 -1;
    1 0 -1; -1 0 1;
    0 1 1; 0 -1 -1;
    0 1 -1; 0 -1 1
];
% normalize diagonal directions
dirs18 = normalize_rows(dirs18);

% choose DOP set here (change to dirs18 to get better resolution)
directions = dirs6;

% ========== STATE ==========
moveDir = [0 0 0];   % velocity direction controlled by keys
running = true;

% ========== FIGURE ==========
fig = figure('Name','DOP Collision Demo', ...
             'NumberTitle','off', ...
             'Color',[1 1 1], ...
             'KeyPressFcn',@keyDown, ...
             'KeyReleaseFcn',@keyUp, ...
             'CloseRequestFcn',@onClose);

ax = axes(fig);
hold(ax,'on');
axis(ax,'equal');
grid(ax,'on');
view(45,25);
xlabel('X'); ylabel('Y'); zlabel('Z');

% draw sphere mesh
[sX, sY, sZ] = sphere(num_points);
sX = sX * sphere_radius;
sY = sY * sphere_radius;
sZ = sZ * sphere_radius;

sphereSurf = surf(ax, sX + sphere_pos(1), ...
                      sY + sphere_pos(2), ...
                      sZ + sphere_pos(3), ...
                  'FaceColor','b','FaceAlpha',0.45,'EdgeColor','none');

% draw ellipsoid mesh
[eX, eY, eZ] = sphere(num_points);
eX = eX * ellipsoid_radii(1);
eY = eY * ellipsoid_radii(2);
eZ = eZ * ellipsoid_radii(3);

ellipsoidSurf = surf(ax, eX + ellipsoid_pos(1), ...
                         eY + ellipsoid_pos(2), ...
                         eZ + ellipsoid_pos(3), ...
                     'FaceColor','r','FaceAlpha',0.45,'EdgeColor','none');

title(ax,'No Collision','Color','k');
camlight(ax,'headlight');
material(ax,'dull');

disp('Use arrow keys to move the sphere. Press ESC to quit.');

% ========== MAIN LOOP ==========
while running && ishghandle(fig)
    % update position
    sphere_pos = sphere_pos + moveDir * move_speed;

    % sample points on surfaces
    sphere_pts = get_sphere_points(sphere_pos, sphere_radius, num_points);
    ellipsoid_pts = get_ellipsoid_points(ellipsoid_pos, ellipsoid_radii, num_points);

    % compute DOPs
    dop_sphere = compute_DOP(sphere_pts, directions);
    dop_ellipsoid = compute_DOP(ellipsoid_pts, directions);

    % collision test
    collision = is_colliding_DOP(dop_sphere, dop_ellipsoid);

    if collision
        title(ax,'⚠ Collision Detected','Color','r');
    else
        title(ax,'No Collision','Color','k');
    end

    % update visual meshes
    set(sphereSurf, 'XData', sX + sphere_pos(1), ...
                    'YData', sY + sphere_pos(2), ...
                    'ZData', sZ + sphere_pos(3));
    % ellipsoid is static here; if you want it moving, update similarly

    drawnow limitrate;
    pause(dt);
end

if ishghandle(fig)
    delete(fig);
end

% ========== NESTED CALLBACKS (can modify moveDir / running) ==========
    function keyDown(~, event)
        switch event.Key
            case 'leftarrow'
                moveDir = [-1 0 0];
            case 'rightarrow'
                moveDir = [1 0 0];
            case 'uparrow'
                moveDir = [0 1 0];
            case 'downarrow'
                moveDir = [0 -1 0];
            case 'pagedown'   % move down in Z
                moveDir = [0 0 -1];
            case 'pageup'     % move up in Z
                moveDir = [0 0 1];
            case 'escape'
                running = false;
        end
    end

    function keyUp(~, event)
        switch event.Key
            case {'leftarrow','rightarrow','uparrow','downarrow','pageup','pagedown'}
                moveDir = [0 0 0];
        end
    end

    function onClose(~, ~)
        running = false;
        delete(fig);
    end

end  % end of main function dop_collision_sim

% ========== LOCAL / HELPER FUNCTIONS ==========
function pts = get_sphere_points(center, radius, num_points)
    % Return Nx3 array of sampled points on sphere surface
    nPhi = max(4, round(num_points/2));
    nTheta = max(8, num_points);
    phi = linspace(0, pi, nPhi);
    theta = linspace(0, 2*pi, nTheta);
    pts = zeros(nPhi * nTheta, 3);
    idx = 1;
    for i = 1:nPhi
        for j = 1:nTheta
            p = phi(i); t = theta(j);
            x = center(1) + radius * sin(p) * cos(t);
            y = center(2) + radius * sin(p) * sin(t);
            z = center(3) + radius * cos(p);
            pts(idx, :) = [x y z];
            idx = idx + 1;
        end
    end
end

function pts = get_ellipsoid_points(center, radii, num_points)
    % Return Nx3 array of sampled points on ellipsoid surface
    nPhi = max(4, round(num_points/2));
    nTheta = max(8, num_points);
    phi = linspace(0, pi, nPhi);
    theta = linspace(0, 2*pi, nTheta);
    pts = zeros(nPhi * nTheta, 3);
    idx = 1;
    for i = 1:nPhi
        for j = 1:nTheta
            p = phi(i); t = theta(j);
            x = center(1) + radii(1) * sin(p) * cos(t);
            y = center(2) + radii(2) * sin(p) * sin(t);
            z = center(3) + radii(3) * cos(p);
            pts(idx, :) = [x y z];
            idx = idx + 1;
        end
    end
end

function dop = compute_DOP(points, directions)
    % points: Mx3, directions: Dx3 (rows are directions)
    % dop.min_proj and dop.max_proj are Dx1
    projs = points * directions';      % (M x D)
    dop.min_proj = min(projs, [], 1)'; % D x 1
    dop.max_proj = max(projs, [], 1)'; % D x 1
    dop.directions = directions;
end

function tf = is_colliding_DOP(dopA, dopB)
    % Returns true if DOP A and B overlap on all directions (no separating axis)
    D = size(dopA.directions, 1);
    tf = true;
    for i = 1:D
        if dopA.max_proj(i) < dopB.min_proj(i) || dopA.min_proj(i) > dopB.max_proj(i)
            tf = false;
            return;
        end
    end
end

function M = normalize_rows(M)
    % normalize each row to unit length
    for r = 1:size(M,1)
        nrm = norm(M(r,:));
        if nrm > 0
            M(r,:) = M(r,:) / nrm;
        end
    end
end
