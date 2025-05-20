function Order = entropy_based_ordering(Data)
    [n, d] = size(Data);
    MI = zeros(d);
    Dep = zeros(d);
    
    for i = 1:d
        for j = i+1:d
            MI(i,j) = mutual_info(Data(:,i), Data(:,j));
            MI(j,i) = MI(i,j);
        end
    end

    for i = 1:d
        for j = i+1:d
            pass = true;
            for k = setdiff(1:d, [i j])
                if ~(MI(i,j) > MI(i,k) || MI(i,j) > MI(k,j))
                    pass = false;
                    break;
                end
            end
            if pass
                Dep(i,j) = 1;
                Dep(j,i) = 1;
            end
        end
    end

    Dir = zeros(d); % Directed adjacency matrix
    for i = 1:d
        for j = i+1:d
            if Dep(i,j) == 1
                Hx = entropy_hist(Data(:,i));
                Hy = entropy_hist(Data(:,j));
                Hx_y = conditional_entropy(Data(:,i), Data(:,j));
                Hy_x = conditional_entropy(Data(:,j), Data(:,i));
                states_x = length(unique(Data(:,i)));
                states_y = length(unique(Data(:,j)));

                CR_yx = Hx_y / (Hx * states_x);
                CR_xy = Hy_x / (Hy * states_y);

                if CR_yx < CR_xy
                    Dir(j,i) = 1; % j --> i
                else
                    Dir(i,j) = 1; % i --> j
                end
            end
        end
    end

    G = digraph(Dir);
    Order = toposort(G);
end

function H = entropy_hist(X)
    p = histcounts(X, 'Normalization', 'probability');
    p = p(p > 0); % Avoid log(0)
    H = -sum(p .* log2(p));
end

function H = conditional_entropy(X, Y)
    uy = unique(Y);
    H = 0;
    for i = 1:length(uy)
        idx = Y == uy(i);
        px = histcounts(X(idx), 'Normalization', 'probability');
        px = px(px > 0);
        Hy = -sum(px .* log2(px));
        H = H + (sum(idx) / length(X)) * Hy;
    end
end

function I = mutual_info(X, Y)
    Hx = entropy_hist(X);
    Hxy = conditional_entropy(X, Y);
    I = Hx - Hxy;
end
