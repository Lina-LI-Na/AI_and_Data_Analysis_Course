function main
    % 主程序入口
    clc; clear; close all;

    % 示例：欧拉角与平移转换为齐次变换矩阵
    robot_p = [1086.884, -0.612, 1044.939, -179.923, 1.949, 179.88];
    T = euler_translation_to_matrix(robot_p(4:6), robot_p(1:3));
    disp('Transformation Matrix:');
    disp(T);

    % ---------------- 示例数据 ---------------- %
    data = {
        [1086.884, -0.612, 1044.939, -179.923, 1.949, 179.88], [-39.91874987639286, -98.31276281507589, 971.8452257075681];
        [568.093, -22.279, 913.415, -178.17, 32.25, 179.923], [-105.72992056955273, -159.84090778079624, 996.9915928502702];
        [582.382, -388.091, 855.271, -177.715, 29.657, -146.672], [171.06292679324426, -93.49624657942313, 1058.489739704327];
        [572.674, 478.445, 844.468, 179.962, 28.443, 140.389], [11.338792489164481, -52.522664013680966, 950.9235025568703];
        [930.977, 760.975, 816.54, 178.425, 30.039, 87.639], [-88.8633224863508, -101.04699799856027, 886.4901435443461];
        [1293.459, 608.031, 802.548, 178.768, 23.254, 50.019], [-106.76194576866281, 3.4930064029110355, 803.1315693417898];
        [1564.45, 270.617, 922.736, 179.486, 15.384, 9.151], [10.13428374368679, 171.93901934665877, 916.3243955588705];
        [1497.695, -114.409, 922.749, -160.866, 9.862, 13.197], [-41.08199756544106, 184.52574845060587, 952.0665560196218];
        [1410.971, -357.438, 922.725, -150.537, 4.03, 14.926], [-94.39262437789576, 182.7600519003722, 1031.0022775819575];
        [1209.29, -362.991, 722.752, -144.045, -1.704, 9.554], [-138.16580938997387, 132.3303646081262, 842.5858538810055];
    };

    % Base坐标系下的目标点
    target_coords_base = [
        1171.24531, 231.23035, -88.3618759, 1;
        1171.24531, 231.23035, -88.3618759, 1;
        1171.58529, 230.664425, -87.974087, 1;
        1171.07115, 229.041494, -89.0366635, 1;
        1171.06311, 232.058461, -88.0789100, 1;
        1171.61558, 231.148434, -87.7309711, 1;
        1171.40191, 230.492088, -87.5490644, 1;
        1170.89435, 230.738430, -88.0710402, 1;
        1171.27775, 231.340065, -88.1580655, 1;
        1171.58527, 231.056687, -88.0441553, 1;
    ];

    % ---------------- 计算 T_fc ---------------- %
    T_fc = compute_camera_to_flange(data, target_coords_base);
    disp('Transformation Matrix from Flange to Camera:');
    disp(T_fc);
end


% ---------------- 辅助函数定义区 ---------------- %

function T = euler_translation_to_matrix(angles, translation)
    % 欧拉角（XYZ顺序，单位：度）和平移向量 -> 4x4 齐次变换矩阵
    R = eul2rotm(deg2rad(angles), 'XYZ');
    T = [R, translation(:); 0, 0, 0, 1];
end

function T = estimate_transformation(source_points, target_points)
    % 使用SVD估计点集之间的刚性变换矩阵
    src_mean = mean(source_points, 1);
    tgt_mean = mean(target_points, 1);
    
    src_centered = source_points - src_mean;
    tgt_centered = target_points - tgt_mean;
    
    H = src_centered' * tgt_centered;
    [U, ~, V] = svd(H);
    
    R = V * U';
    if det(R) < 0
        V(:, end) = -V(:, end);
        R = V * U';
    end
    
    t = tgt_mean' - R * src_mean';
    
    T = eye(4);
    T(1:3, 1:3) = R;
    T(1:3, 4) = t;
end

function T_fc = compute_camera_to_flange(data, target_coords_base)
    % 计算相机到法兰的变换矩阵
    n = size(data, 1);
    source_points = zeros(n, 3);
    target_points = zeros(n, 3);
    
    for i = 1:n
        pose = data{i,1};
        camera_coords = data{i,2};
        target_coord = target_coords_base(i, :)';
        
        T_bf = euler_translation_to_matrix(pose(4:6), pose(1:3));
        T_bf_inv = inv(T_bf);
        
        target_flange = T_bf_inv * target_coord;
        source_points(i,:) = camera_coords(1:3);
        target_points(i,:) = target_flange(1:3)';
    end
    
    T_fc = estimate_transformation(source_points, target_points);
end

