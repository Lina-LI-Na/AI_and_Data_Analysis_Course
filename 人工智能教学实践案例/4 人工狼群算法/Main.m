%% 狼群算法（Wolf Swarm Algorithm）多目标优化 - 修正版

clear; clc; close all;

% ========== 定义目标函数 ==========
function fitness = Rtotal_multi(x)
    L = 32e-3;
    vn = 1e-6;
    rho = 1000;
    kf = 0.595;
    tb = 1e-3;
    ka = 160;
    Pr = 7;
    cp = 4183;
    
    n = x(1); wc = x(2); V = x(3); h = x(4);
    
    wf = (L - n * wc) / (n + 1);
    
    % 确保不出现负数或零
    if wf <= 1e-10 || n <= 0 || wc <= 0 || V <= 0 || h <= 0
        fitness = [1e10, 1e10, 1e10];
        return;
    end
    
    At = L^2;
    Ab = wc * (L - 2 * wf);
    Aw = h * (L - 2 * wf - wc);
    Dh = 2 * wc * h / (wc + h);
    
    if Dh <= 0
        fitness = [1e10, 1e10, 1e10];
        return;
    end
    
    Re = V * Dh / vn;
    G = ((wc/h)^2 + 1) / ((wc/h) + 1)^2;
    Nu1 = 8.31 * G - 0.02;
    L1 = Re * Dh * Pr / (L - wf);
    Nu = ((2.22 * L1^0.33)^3 + Nu1^3)^(1/3);
    hf = Nu * kf / Dh;
    
    R1 = tb / (ka * At);
    m = sqrt(hf / (ka * wf));
    enta = tanh(m * h) / (m * h);
    As = n * Ab + 2 * Aw * n * enta;
    R2 = 1 / (hf * As);
    Rt = R1 + R2;
    
    fitness(1) = Rt + 1 / (h * wc * V * rho * cp);
    
    a = h / wc;
    b = wf / wc;
    L2 = Re * Dh / (L - wf);
    fl = (19.64 * G + 4.7) / Re;
    f = ((3.2 * L2^0.57)^2 + (fl * Re)^2)^0.5 / Re;
    
    if a >= 1 && b <= 2
        if Re >= 1000
            fw = 8.09 * (1 - 0.3439*a + 0.042*a^2) * (1 - 0.3315*b + 0.1042*b^2);
        else
            fw = 100000;
        end
    else
        if Re < 1000
            fw = 0.46 * Re^(1/3) * (1 - 0.2*a + 0.0022*a^2) * (1 + 0.26*b^(2/3) - 0.0018*b^2);
        else
            fw = 3.8 * (1 - 0.1*a + 0.0063*a^2) * (1 + 0.12*b^(2/3) - 0.0003*b^2);
        end
    end
    
    pz1 = 2 * f * (L - wf) * rho * V^2 / Dh;
    pz2 = 2 * f * (L - 2*wf) * rho * V^2 / Dh;
    pw = 0.5 * fw * rho * V^2;
    P = 2 * pz1 + (n - 2) * pz2 + (n - 1) * pw;
    
    fitness(2) = P;
    
    penalty_wf = max(0, 0.0002 - wf);
    penalty_Re = max(0, Re - 2300);
    fitness(3) = penalty_wf + penalty_Re;
end

% ========== 狼群算法主程序（修正版） ==========
function [pareto_front, pareto_solutions] = wolf_swarm_algorithm()
    % 参数设置
    nVar = 4;           % 变量个数
    LB = [4, 1e-3, 0.1, 2e-3];  % 下界
    UB = [20, 4e-3, 2, 5e-3];   % 上界
    
    % 狼群算法参数
    nWolf = 50;         % 狼群数量
    maxGen = 100;       % 最大代数
    visual = 0.3;       % 视野范围
    step = 0.1;         % 移动步长
    trynum = 5;         % 尝试次数
    crowd = 0.5;        % 拥挤度因子
    
    % 初始化狼群
    wolves = zeros(nWolf, nVar);
    fitness = zeros(nWolf, 3);  % 三目标
    
    for i = 1:nWolf
        wolves(i,:) = LB + (UB - LB) .* rand(1, nVar);
        fitness(i,:) = Rtotal_multi(wolves(i,:));
    end
    
    % 主循环
    for gen = 1:maxGen
        fprintf('Generation %d\n', gen);
        
        % 获取当前狼群数量
        current_nWolf = size(wolves, 1);
        
        % 根据适应度排序（找到alpha, beta, delta狼）
        % 这里使用简单的支配排序
        [sorted_idx] = non_dominated_sort(fitness);
        
        % 更新狼的位置
        for i = 1:current_nWolf
            % 选择领导狼（排名靠前的）
            if length(sorted_idx) > 0
                leader_idx = sorted_idx(randi([1, min(5, length(sorted_idx))]));
                
                % 计算距离
                distance = norm(wolves(i,:) - wolves(leader_idx,:));
                
                if distance < visual
                    % 如果视野内有更好的狼，向它移动
                    wolves(i,:) = wolves(i,:) + ...
                        step * (wolves(leader_idx,:) - wolves(i,:)) ./ distance;
                else
                    % 随机移动
                    wolves(i,:) = wolves(i,:) + step * (rand(1,nVar)-0.5) .* (UB-LB);
                end
                
                % 边界检查
                wolves(i,:) = max(LB, min(UB, wolves(i,:)));
                
                % 更新适应度
                fitness(i,:) = Rtotal_multi(wolves(i,:));
            end
        end
        
        % 拥挤度控制（移除过于相似的解）- 修正版
        if mod(gen, 10) == 0 && size(wolves, 1) > 20
            [wolves, fitness] = crowding_control(wolves, fitness, crowd);
        end
        
        % 尝试改进（trynum次尝试）
        current_nWolf = size(wolves, 1);  % 更新当前狼群数量
        for i = 1:current_nWolf
            best_pos = wolves(i,:);
            best_fit = fitness(i,:);
            
            for try_idx = 1:trynum
                % 随机扰动
                new_pos = wolves(i,:) + 0.1 * (rand(1,nVar)-0.5) .* (UB-LB);
                new_pos = max(LB, min(UB, new_pos));
                new_fit = Rtotal_multi(new_pos);
                
                % 如果新位置更好（支配原位置）
                if all(new_fit <= best_fit) && any(new_fit < best_fit)
                    best_pos = new_pos;
                    best_fit = new_fit;
                end
            end
            
            wolves(i,:) = best_pos;
            fitness(i,:) = best_fit;
        end
        
        % 显示当前帕累托前沿大小
        [front, ~] = find_pareto_front(fitness, wolves);
        fprintf('  Pareto front size: %d\n', size(front, 1));
        
        % 保持最小种群数量
        if size(wolves, 1) < 20
            % 补充新狼
            add_wolves = 20 - size(wolves, 1);
            new_wolves = zeros(add_wolves, nVar);
            new_fitness = zeros(add_wolves, 3);
            
            for i = 1:add_wolves
                new_wolves(i,:) = LB + (UB - LB) .* rand(1, nVar);
                new_fitness(i,:) = Rtotal_multi(new_wolves(i,:));
            end
            
            wolves = [wolves; new_wolves];
            fitness = [fitness; new_fitness];
        end
    end
    
    % 找到最终的帕累托前沿
    [pareto_front, pareto_solutions] = find_pareto_front(fitness, wolves);
end

% ========== 辅助函数 ==========

% 非支配排序（简化版）
function sorted_idx = non_dominated_sort(fitness)
    n = size(fitness, 1);
    rank = zeros(n, 1);
    
    for i = 1:n
        for j = 1:n
            if i ~= j
                % 检查j是否支配i
                if all(fitness(j,:) <= fitness(i,:)) && any(fitness(j,:) < fitness(i,:))
                    rank(i) = rank(i) + 1;
                end
            end
        end
    end
    
    [~, sorted_idx] = sort(rank);
end

% 拥挤度控制（修正版）
function [new_wolves, new_fitness] = crowding_control(wolves, fitness, threshold)
    n = size(wolves, 1);
    
    if n <= 1
        new_wolves = wolves;
        new_fitness = fitness;
        return;
    end
    
    distances = zeros(n, n);
    
    % 计算个体间距离
    for i = 1:n
        for j = i+1:n
            distances(i,j) = norm(wolves(i,:) - wolves(j,:));
            distances(j,i) = distances(i,j);
        end
    end
    
    % 找到过于相似的个体
    to_remove = [];
    for i = 1:n
        for j = i+1:n
            if distances(i,j) < threshold && isempty(find(to_remove == i, 1))
                to_remove = [to_remove, j];
            end
        end
    end
    
    % 保留索引
    keep_idx = setdiff(1:n, to_remove);
    
    % 确保至少保留一定数量的个体
    min_population = 20;
    if length(keep_idx) < min_population
        % 计算每个个体的拥挤度（基于目标空间的距离）
        crowding_distances = zeros(n, 1);
        for obj_idx = 1:size(fitness, 2)
            [sorted_fit, sort_idx] = sort(fitness(:, obj_idx));
            crowding_distances(sort_idx(1)) = inf;
            crowding_distances(sort_idx(end)) = inf;
            
            for i = 2:(n-1)
                crowding_distances(sort_idx(i)) = crowding_distances(sort_idx(i)) + ...
                    (sorted_fit(i+1) - sorted_fit(i-1)) / (sorted_fit(end) - sorted_fit(1));
            end
        end
        
        % 按拥挤度排序，保留拥挤度最大的个体
        [~, sorted_by_crowding] = sort(crowding_distances, 'descend');
        keep_idx = sorted_by_crowding(1:min_population);
    end
    
    % 提取保留的个体
    new_wolves = wolves(keep_idx, :);
    new_fitness = fitness(keep_idx, :);
end

% 找到帕累托前沿
function [front, solutions] = find_pareto_front(fitness, solutions)
    n = size(fitness, 1);
    
    if n == 0
        front = [];
        solutions = [];
        return;
    end
    
    is_dominated = false(n, 1);
    
    for i = 1:n
        for j = 1:n
            if i ~= j
                % 检查j是否支配i
                if all(fitness(j,:) <= fitness(i,:)) && any(fitness(j,:) < fitness(i,:))
                    is_dominated(i) = true;
                    break;
                end
            end
        end
    end
    
    % 提取非支配解
    front = fitness(~is_dominated, :);
    solutions = solutions(~is_dominated, :);
end

% ========== 主程序 ==========
fprintf('开始狼群算法多目标优化...\n');
fprintf('算法参数：\n');
fprintf('  狼群数量：50\n');
fprintf('  最大代数：100\n');
fprintf('  视野范围：0.3\n');
fprintf('  移动步长：0.1\n');
fprintf('  尝试次数：5\n');
fprintf('  拥挤度因子：0.5\n\n');

try
    tic;
    [pareto_front, pareto_solutions] = wolf_swarm_algorithm();
    elapsed_time = toc;
    
    fprintf('\n优化完成！耗时：%.2f 秒\n', elapsed_time);
    fprintf('帕累托前沿包含 %d 个非支配解：\n', size(pareto_front, 1));
    
    % 显示前5个最优解
    num_to_show = min(5, size(pareto_front, 1));
    for i = 1:num_to_show
        fprintf('\n解 %d：\n', i);
        fprintf('  通道数 n = %.2f\n', pareto_solutions(i,1));
        fprintf('  通道宽度 wc = %.6f m\n', pareto_solutions(i,2));
        fprintf('  入口速度 V = %.4f m/s\n', pareto_solutions(i,3));
        fprintf('  散热器高度 h = %.6f m\n', pareto_solutions(i,4));
        fprintf('  目标函数值：\n');
        fprintf('    热阻 Rt = %.6e K/W\n', pareto_front(i,1));
        fprintf('    压力损失 P = %.4f Pa\n', pareto_front(i,2));
        fprintf('    约束惩罚 = %.6f\n', pareto_front(i,3));
    end
    
    % 绘制帕累托前沿
    if size(pareto_front, 1) >= 2
        figure('Position', [100, 100, 1200, 500]);
        
        % 子图1：帕累托前沿
        subplot(1,2,1);
        scatter(pareto_front(:,1), pareto_front(:,2), 40, 'b', 'filled');
        xlabel('目标1：散热器热阻 Rt (K/W)');
        ylabel('目标2：总压力损失 P (Pa)');
        title('狼群算法得到的帕累托前沿');
        grid on;
        
        % 子图2：变量分布
        subplot(1,2,2);
        if size(pareto_solutions, 1) > 1
            plot(pareto_solutions, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8);
        else
            bar(pareto_solutions);
        end
        xlabel('解编号');
        ylabel('变量值');
        title('决策变量分布');
        legend({'n (通道数)', 'wc (通道宽度)', 'V (入口速度)', 'h (散热器高度)'}, ...
            'Location', 'best');
        grid on;
        
        % 保存结果
        save('wolf_swarm_results.mat', 'pareto_front', 'pareto_solutions');
        fprintf('\n结果已保存到 wolf_swarm_results.mat\n');
    end
    
    % ========== 结果分析 ==========
    fprintf('\n========== 结果分析 ==========\n');
    
    if size(pareto_front, 1) > 0
        % 找到热阻最小的解
        [min_rt, idx_rt] = min(pareto_front(:,1));
        fprintf('热阻最小的解：\n');
        fprintf('  热阻：%.6e K/W，压力损失：%.4f Pa\n', ...
            pareto_front(idx_rt,1), pareto_front(idx_rt,2));
        
        % 找到压力损失最小的解
        [min_p, idx_p] = min(pareto_front(:,2));
        fprintf('压力损失最小的解：\n');
        fprintf('  热阻：%.6e K/W，压力损失：%.4f Pa\n', ...
            pareto_front(idx_p,1), pareto_front(idx_p,2));
        
        % 找到平衡解（距离原点最近）
        if size(pareto_front, 1) > 1
            normalized_rt = (pareto_front(:,1) - min(pareto_front(:,1))) / ...
                (max(pareto_front(:,1)) - min(pareto_front(:,1)));
            normalized_p = (pareto_front(:,2) - min(pareto_front(:,2))) / ...
                (max(pareto_front(:,2)) - min(pareto_front(:,2)));
            distance = sqrt(normalized_rt.^2 + normalized_p.^2);
            [~, idx_balanced] = min(distance);
            
            fprintf('平衡解（综合考虑）：\n');
            fprintf('  热阻：%.6e K/W，压力损失：%.4f Pa\n', ...
                pareto_front(idx_balanced,1), pareto_front(idx_balanced,2));
            fprintf('  参数：n=%.2f, wc=%.6f, V=%.4f, h=%.6f\n', ...
                pareto_solutions(idx_balanced,1), pareto_solutions(idx_balanced,2), ...
                pareto_solutions(idx_balanced,3), pareto_solutions(idx_balanced,4));
        end
    end
    
catch ME
    fprintf('\n运行出错！错误信息：\n');
    fprintf('错误信息：%s\n', ME.message);
    fprintf('错误位置：%s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
    
    % 尝试保存已有结果
    if exist('pareto_front', 'var') && ~isempty(pareto_front)
        save('wolf_swarm_results_partial.mat', 'pareto_front', 'pareto_solutions');
        fprintf('部分结果已保存到 wolf_swarm_results_partial.mat\n');
    end
end