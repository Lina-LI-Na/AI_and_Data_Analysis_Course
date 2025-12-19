function robot_pick_place()
    clc; close all;
    
    fprintf('========== MATLAB抓取放置任务模拟器 ==========\n');
    fprintf('版本: 纯MATLAB实现，无需ROS Toolbox\n');
    fprintf('时间: %s\n', datestr(now));
    fprintf('=============================================\n\n');
    
    % 创建可视化界面
    createVisualization();
    
    % 初始化模拟参数
    fprintf('初始化模拟参数...\n');
    [robot_state, object_params] = initializeSimulation();
    
    % 计算物体在机器人基座坐标系中的位置
    fprintf('计算物体位置...\n');
    [target_position, T_rf, T_fc] = calculateObjectPosition(robot_state, object_params);
    
    % 显示计算结果
    displayResults(robot_state, object_params, target_position, T_rf, T_fc);
    
    % 执行抓取放置任务序列
    fprintf('\n========== 开始抓取放置任务 ==========\n');
    
    % 记录所有步骤
    steps = {};
    
    % 步骤1: 移动到物体上方
    steps{end+1} = struct('name', '移动到物体上方', ...
                          'position', [target_position(1), target_position(2), 0.3974], ...
                          'duration', 2);
    
    % 步骤2: 下降到物体
    target_z = max(target_position(3) - 0.01, 0.05);
    steps{end+1} = struct('name', '下降到物体上方', ...
                          'position', [target_position(1), target_position(2), target_z], ...
                          'duration', 2);
    
    % 步骤3: 抓取物体
    steps{end+1} = struct('name', '抓取物体', ...
                          'action', 'grasp', ...
                          'duration', 1);
    
    % 步骤4: 提起物体
    steps{end+1} = struct('name', '提起物体', ...
                          'position', [target_position(1), target_position(2), 0.45], ...
                          'duration', 2);
    
    % 步骤5: 移动到中间位置
    steps{end+1} = struct('name', '移动到中间位置', ...
                          'position', [-0.225, 0.087, 0.3974], ...
                          'duration', 2);
    
    % 步骤6: 下降到放置位置
    steps{end+1} = struct('name', '下降到放置位置', ...
                          'position', [-0.225, 0.087, 0.05], ...
                          'duration', 2);
    
    % 步骤7: 释放物体
    steps{end+1} = struct('name', '释放物体', ...
                          'action', 'release', ...
                          'duration', 1);
    
    % 步骤8: 抬起到安全高度
    steps{end+1} = struct('name', '抬起到安全高度', ...
                          'position', [-0.225, 0.087, 0.45], ...
                          'duration', 2);
    
    % 步骤9: 返回等待位置
    steps{end+1} = struct('name', '返回等待位置', ...
                          'position', [-0.225, 0.087, 0.397], ...
                          'duration', 2);
    
    % 执行所有步骤
    for i = 1:length(steps)
        executeStep(i, steps{i});
        
        % 模拟hand参数检查
        if mod(i, 2) == 0 || isfield(steps{i}, 'action')
            checkHandParameter(i+3);
        end
    end
    
    fprintf('\n========== 抓取放置任务完成 ==========\n');
    
    % 保存结果到文件
    saveResultsToFile(robot_state, object_params, target_position, steps);
    
    fprintf('\n模拟任务已完成！\n');
    fprintf('结果已保存到 "pick_and_place_results.mat"\n');
    fprintf('感谢使用MATLAB抓取放置任务模拟器\n');
end

function createVisualization()
    % 创建简单的可视化界面
    fprintf('创建可视化界面...\n');
    
    % 创建主窗口
    fig = figure('Name', '机器人抓取放置模拟', ...
                 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1200, 800]);
    
    % 创建进度条
    ax_progress = axes('Parent', fig, 'Position', [0.1, 0.05, 0.8, 0.1]);
    progress_bar = fill([0, 0, 0, 0], [0, 1, 1, 0], 'b', 'FaceAlpha', 0.3);
    axis(ax_progress, [0, 10, 0, 1]);
    title(ax_progress, '任务进度');
    xlabel(ax_progress, '步骤');
    ylabel(ax_progress, '完成度');
    set(ax_progress, 'XTick', 0:10, 'YTick', 0:0.25:1);
    grid(ax_progress, 'on');
    
    % 创建状态显示区域
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '任务状态: 准备开始', ...
              'Position', [50, 700, 1100, 30], ...
              'FontSize', 14, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'center', ...
              'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % 创建日志显示区域
    log_text = uicontrol('Parent', fig, ...
                         'Style', 'edit', ...
                         'String', '任务日志:', ...
                         'Position', [50, 50, 1100, 620], ...
                         'FontSize', 10, ...
                         'HorizontalAlignment', 'left', ...
                         'Max', 1000, ...
                         'Min', 1, ...
                         'Enable', 'inactive');
    
    % 保存句柄以便后续更新
    handles = struct('fig', fig, ...
                     'progress_bar', progress_bar, ...
                     'log_text', log_text);
    setappdata(fig, 'handles', handles);
    
    % 更新日志
    updateLog('可视化界面创建完成');
end

function updateLog(message)
    % 更新日志显示
    fig = findobj('Name', '机器人抓取放置模拟');
    if ~isempty(fig)
        handles = getappdata(fig, 'handles');
        current_text = get(handles.log_text, 'String');
        
        % 添加时间戳
        timestamp = datestr(now, 'HH:MM:SS');
        new_message = sprintf('[%s] %s', timestamp, message);
        
        % 检查current_text的类型
        if iscell(current_text)
            % 如果是cell数组，直接添加新字符串
            updated_text = [current_text; {new_message}];
        else
            % 如果是字符串或字符数组，转换为cell数组
            updated_text = {current_text; new_message};
        end
        
        % 限制日志行数，防止过多
        if length(updated_text) > 50
            updated_text = updated_text(end-49:end);
        end
        
        % 更新文本
        set(handles.log_text, 'String', updated_text);
        
        % 滚动到底部
        set(handles.log_text, 'ListboxTop', max(1, length(updated_text) - 10));
    end
    
    % 同时在命令行显示
    fprintf('%s\n', message);
end

function updateProgress(step, total_steps)
    % 更新进度条
    fig = findobj('Name', '机器人抓取放置模拟');
    if ~isempty(fig)
        handles = getappdata(fig, 'handles');
        
        % 更新进度条
        progress = step / total_steps;
        set(handles.progress_bar, 'XData', [0, progress, progress, 0]);
        
        % 更新标题
        axes_handle = get(handles.progress_bar, 'Parent');
        title(axes_handle, sprintf('任务进度: %.1f%%', progress * 100));
        
        drawnow;
    end
end

function [robot_state, object_params] = initializeSimulation()
    % 初始化机器人状态
    robot_state = struct();
    robot_state.base_to_flange_translation = [0.5, 0.0, 0.5];  % [x, y, z] in meters
    robot_state.base_to_flange_rotation = [0.0, 0.0, 0.0];     % [rx, ry, rz] in radians
    
    % 初始化物体参数
    object_params = struct();
    object_params.camera_position = [0.1, 0.2, 0.3];  % [x, y, z] in meters
    
    updateLog('模拟参数初始化完成');
end

function [target_position, T_rf, T_fc] = calculateObjectPosition(robot_state, object_params)
    % 计算物体在机器人基座坐标系中的位置
    
    % 构造机器人基座到法兰盘的变换矩阵 T_rf
    T_rf = euler_translation_to_matrix(robot_state.base_to_flange_rotation, ...
                                        robot_state.base_to_flange_translation);
    
    % 已知的法兰到相机变换矩阵 T_fc
    T_fc = [
       -9.98014822e-01, -6.25576599e-02,  7.27699459e-03, -9.86987541e+01;
        6.25362045e-02, -9.98037758e-01, -3.13970271e-03,  1.40914497e+02;
        7.45912782e-03, -2.67839422e-03,  9.99968593e-01,  1.63618325e+02;
        0, 0, 0, 1
    ];
    
    % 相机坐标系中的物体位置
    P_c = [object_params.camera_position, 1]';  % 齐次坐标
    
    % 将相机坐标转换为机器人基座坐标
    P_t = T_rf * T_fc * P_c;
    target_position = P_t(1:3)';
    
    updateLog(sprintf('物体位置计算完成: [%.6f, %.6f, %.6f]', ...
                     target_position(1), target_position(2), target_position(3)));
end

function displayResults(robot_state, object_params, target_position, T_rf, T_fc)
    % 显示计算结果
    
    updateLog('========== 计算结果 ==========');
    updateLog(sprintf('机器人末端位置: [%.3f, %.3f, %.3f]', ...
                     robot_state.base_to_flange_translation));
    updateLog(sprintf('机器人末端姿态: [%.3f, %.3f, %.3f] rad', ...
                     robot_state.base_to_flange_rotation));
    updateLog(sprintf('相机坐标系中的物体位置: [%.3f, %.3f, %.3f]', ...
                     object_params.camera_position));
    updateLog(sprintf('机器人基座坐标系中的物体位置: [%.6f, %.6f, %.6f]', ...
                     target_position(1), target_position(2), target_position(3)));
    updateLog('==============================');
end

function executeStep(step_num, step_info)
    % 执行单个步骤
    
    updateLog(sprintf('\n步骤 %d: %s', step_num, step_info.name));
    
    % 更新状态显示
    fig = findobj('Name', '机器人抓取放置模拟');
    if ~isempty(fig)
        status_text = findobj(fig, 'Style', 'text');
        if ~isempty(status_text)
            set(status_text(1), 'String', sprintf('任务状态: %s (步骤 %d)', step_info.name, step_num));
        end
    end
    
    % 根据步骤类型执行不同的操作
    if isfield(step_info, 'action')
        % 动作步骤（抓取/释放）
        if strcmp(step_info.action, 'grasp')
            updateLog('执行夹爪控制: 关闭夹爪');
            updateLog('夹爪位置: 255, 夹爪力: 100');
        elseif strcmp(step_info.action, 'release')
            updateLog('执行夹爪控制: 打开夹爪');
            updateLog('夹爪位置: 0, 夹爪力: 100');
        end
    else
        % 移动步骤
        updateLog(sprintf('目标位置: [%.4f, %.4f, %.4f]', ...
                         step_info.position(1), step_info.position(2), step_info.position(3)));
        updateLog('计算运动轨迹...');
        updateLog('轨迹规划完成');
    end
    
    % 模拟执行时间
    updateLog(sprintf('执行中 (等待 %.1f 秒)...', step_info.duration));
    
    % 创建等待动画
    for t = 1:step_info.duration
        pause(1);
        updateLog(sprintf('  等待 %d 秒完成', t));
    end
    
    updateLog(sprintf('步骤 %d 完成', step_num));
    
    % 更新进度条
    updateProgress(step_num, 9);
end

function checkHandParameter(step_name)
    % 模拟检查hand参数
    
    updateLog(sprintf('检查hand参数 (步骤%s)...', step_name));
    
    % 模拟hand参数值（随机生成0或1）
    hand_value = randi([0, 1]);
    updateLog(sprintf('hand值: %d', hand_value));
    
    if hand_value == 1
        updateLog('等待hand变为0...');
        
        % 模拟等待过程
        for wait_time = 1:5
            pause(1);
            updateLog(sprintf('  等待中... %d秒', wait_time));
            
            % 更新hand值（有一定概率变为0）
            if wait_time >= 3 && rand() > 0.5
                hand_value = 0;
                updateLog('hand已变为0');
                break;
            end
        end
        
        if hand_value == 1
            updateLog('等待超时，继续执行');
        end
    else
        updateLog('hand参数检查通过');
    end
end

function T = euler_translation_to_matrix(angles, translation)
    % 将欧拉角转换为齐次变换矩阵
    % angles: [rx, ry, rz] in radians
    % translation: [x, y, z]
    
    % 确保角度是行向量
    if size(angles, 1) > 1
        angles = angles';
    end
    
    % 分别计算绕X、Y、Z轴的旋转矩阵
    rx = angles(1);
    ry = angles(2);
    rz = angles(3);
    
    % 绕X轴旋转
    Rx = [1, 0, 0; 
          0, cos(rx), -sin(rx); 
          0, sin(rx), cos(rx)];
    
    % 绕Y轴旋转
    Ry = [cos(ry), 0, sin(ry); 
          0, 1, 0; 
          -sin(ry), 0, cos(ry)];
    
    % 绕Z轴旋转
    Rz = [cos(rz), -sin(rz), 0; 
          sin(rz), cos(rz), 0; 
          0, 0, 1];
    
    % XYZ旋转顺序：R = Rz * Ry * Rx
    R = Rz * Ry * Rx;
    
    % 创建齐次变换矩阵
    T = eye(4);
    T(1:3, 1:3) = R;
    T(1:3, 4) = translation(:);
end

function saveResultsToFile(robot_state, object_params, target_position, steps)
    % 保存结果到MAT文件
    
    % 准备保存的数据
    results = struct();
    results.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    results.robot_state = robot_state;
    results.object_params = object_params;
    results.target_position = target_position;
    results.steps = steps;
    
    % 计算变换矩阵
    [T_rf, T_fc] = calculateTransformMatrices(robot_state);
    results.T_rf = T_rf;
    results.T_fc = T_fc;
    
    % 计算任务统计信息
    results.stats = calculateStatistics(steps);
    
    % 保存到文件
    filename = 'pick_and_place_results.mat';
    save(filename, 'results');
    
    updateLog(sprintf('结果已保存到文件: %s', filename));
end

function [T_rf, T_fc] = calculateTransformMatrices(robot_state)
    % 计算变换矩阵
    T_rf = euler_translation_to_matrix(robot_state.base_to_flange_rotation, ...
                                        robot_state.base_to_flange_translation);
    
    T_fc = [
       -9.98014822e-01, -6.25576599e-02,  7.27699459e-03, -9.86987541e+01;
        6.25362045e-02, -9.98037758e-01, -3.13970271e-03,  1.40914497e+02;
        7.45912782e-03, -2.67839422e-03,  9.99968593e-01,  1.63618325e+02;
        0, 0, 0, 1
    ];
end

function stats = calculateStatistics(steps)
    % 计算任务统计信息
    stats = struct();
    stats.total_steps = length(steps);
    stats.total_time = 0;
    stats.move_steps = 0;
    stats.action_steps = 0;
    
    for i = 1:length(steps)
        stats.total_time = stats.total_time + steps{i}.duration;
        
        if isfield(steps{i}, 'action')
            stats.action_steps = stats.action_steps + 1;
        else
            stats.move_steps = stats.move_steps + 1;
        end
    end
    
    stats.average_step_time = stats.total_time / stats.total_steps;
end