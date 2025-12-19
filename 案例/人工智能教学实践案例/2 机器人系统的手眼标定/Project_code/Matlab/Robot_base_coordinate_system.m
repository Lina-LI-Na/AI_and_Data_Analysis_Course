clc; clear; close all;

% ---------- 欧拉角和平移转换为齐次变换矩阵函数 ----------
function T = euler_translation_to_matrix(angles, translation)
    % angles: 欧拉角 [rx, ry, rz] (度)
    % translation: 平移向量 [x, y, z]
    Rm = eul2rotm(deg2rad(angles), 'XYZ'); % 欧拉角转旋转矩阵
    T = [Rm, translation(:); 0, 0, 0, 1];  % 拼接齐次变换矩阵
end

% ---------- 主脚本部分 ----------

% 示例机械臂基座到法兰盘的变换矩阵（已知）
robot_p = [1086.884, -0.612, 1044.939, -179.923, 1.949, 179.88];
T_rf = euler_translation_to_matrix(robot_p(4:6), robot_p(1:3));

% 示例法兰盘到相机的变换矩阵（已知）
T_fc = [
   -9.98014822e-01, -6.25576599e-02,  7.27699459e-03, -9.86987541e+01;
    6.25362045e-02, -9.98037758e-01, -3.13970271e-03,  1.40914497e+02;
    7.45912782e-03, -2.67839422e-03,  9.99968593e-01,  1.63618325e+02;
    0, 0, 0, 1
];

% 示例相机坐标系中的物体坐标
P_c = [-0.234; -0.133; 0.585; 1]; % 列向量形式

% 将相机坐标转换为机械臂基座坐标
P_t = T_rf * T_fc * P_c;

% 提取结果
x_t = P_t(1);
y_t = P_t(2);
z_t = P_t(3);
w_t = P_t(4);

% ---------- 输出 ----------
disp('Object coordinates in the robot base coordinate system:');
disp(P_t.');

fprintf('X: %.6f\n', x_t);
fprintf('Y: %.6f\n', y_t);
fprintf('Z: %.6f\n', z_t);
fprintf('W: %.6f\n', w_t); % 齐次坐标应为1

