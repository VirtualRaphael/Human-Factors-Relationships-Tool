function DAG = npc_structure_learning(LGObj, alpha)
    d = size(LGObj.FreqTable, 2);
    Undirected = ones(d) - eye(d);

    for i = 1:d
        for j = i+1:d
            [MI, R, M] = ConditionallyIndependent_MutualInformation(LGObj, i, j);
            if CITest_ChiTwoVar(MI, R, M, alpha)
                Undirected(i,j) = 0;
                Undirected(j,i) = 0;
            end
        end
    end

    DAG = zeros(d);
    for i = 1:d
        neighbors = find(Undirected(i,:) == 1);
        for j = neighbors
            if i < j
                DAG(i,j) = 1;
            end
        end
    end
end
