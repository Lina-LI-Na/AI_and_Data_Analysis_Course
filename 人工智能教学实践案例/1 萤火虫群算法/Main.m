
clear; clc; close all;

% 定义目标函数
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
    
    % 确保不出现复数（简化处理）
    if wf <= 0 || n <= 0 || wc <= 0 || V <= 0 || h <= 0
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

% 萤火虫多目标优化算法
function [pareto_front, pareto_solutions] = firefly_multiobjective()
    % 参数设置
    nVar = 4;           % 变量个数
    LB = [4, 1e-3, 0.1, 2e-3];  % 下界
    UB = [20, 4e-3, 2, 5e-3];   % 上界
    nFirefly = 50;      % 萤火虫数量
    maxGen = 100;       % 最大代数
    alpha = 0.2;        % 随机性参数
    gamma = 1.0;        % 光吸收系数
    
    % 初始化萤火虫
    fireflies = zeros(nFirefly, nVar);
    fitness = zeros(nFirefly, 3);  % 三目标
    
    for i = 1:nFirefly
        fireflies(i,:) = LB + (UB - LB) .* rand(1, nVar);
        fitness(i,:) = Rtotal_multi(fireflies(i,:));
    end
    
    % 存储帕累托前沿
    pareto_front = [];
    pareto_solutions = [];
    
    % 主循环
    for gen = 1:maxGen
        fprintf('Generation %d\n', gen);
        
        % 更新每个萤火虫
        for i = 1:nFirefly
            for j = 1:nFirefly
                % 计算支配关系（对于最小化问题）
                dominated = false;
                
                % 检查萤火虫j是否支配i（所有目标值都更小或相等，且至少有一个严格更小）
                if all(fitness(j,:) <= fitness(i,:)) && any(fitness(j,:) < fitness(i,:))
                    dominated = true;
                end
                
                if dominated
                    % 计算距离
                    r = norm(fireflies(i,:) - fireflies(j,:));
                    
                    % 计算吸引力
                    beta = exp(-gamma * r^2);
                    
                    % 更新位置
                    fireflies(i,:) = fireflies(i,:) + ...
                        beta * (fireflies(j,:) - fireflies(i,:)) + ...
                        alpha * (rand(1, nVar) - 0.5) .* (UB - LB);
                    
                    % 边界检查
                    fireflies(i,:) = max(LB, min(UB, fireflies(i,:)));
                    
                    % 更新适应度
                    fitness(i,:) = Rtotal_multi(fireflies(i,:));
                end
            end
        end
        
        % 更新帕累托前沿
        [front, solutions] = find_pareto_front(fitness, fireflies);
        pareto_front = front;
        pareto_solutions = solutions;
        
        % 显示当前帕累托前沿大小
        fprintf('  Pareto front size: %d\n', size(pareto_front, 1));
    end
    
    % 找到最终的非支配解
    [pareto_front, pareto_solutions] = find_pareto_front(fitness, fireflies);
end

% 找到帕累托前沿的函数
function [front, solutions] = find_pareto_front(fitness, solutions)
    n = size(fitness, 1);
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

% 运行优化
fprintf('开始萤火虫多目标优化...\n');
tic;
[pareto_front, pareto_solutions] = firefly_multiobjective();
toc;

% 显示结果
fprintf('\n优化完成！\n');
fprintf('帕累托前沿包含 %d 个非支配解:\n', size(pareto_front, 1));

% 显示前5个最优解
num_to_show = min(5, size(pareto_front, 1));
for i = 1:num_to_show
    fprintf('\n解 %d:\n', i);
    fprintf('  通道数 n = %.2f\n', pareto_solutions(i,1));
    fprintf('  通道宽度 wc = %.6f m\n', pareto_solutions(i,2));
    fprintf('  入口速度 V = %.4f m/s\n', pareto_solutions(i,3));
    fprintf('  散热器高度 h = %.6f m\n', pareto_solutions(i,4));
    fprintf('  目标函数值: [%.6e, %.4f, %.6f]\n', ...
        pareto_front(i,1), pareto_front(i,2), pareto_front(i,3));
end

% 绘制帕累托前沿（前两个目标）
if size(pareto_front, 1) >= 2
    figure;
    scatter(pareto_front(:,1), pareto_front(:,2), 40, 'b', 'filled');
    xlabel('目标1: 散热器热阻 Rt (K/W)');
    ylabel('目标2: 总压力损失 P (Pa)');
    title('萤火虫算法得到的帕累托前沿');
    grid on;
end