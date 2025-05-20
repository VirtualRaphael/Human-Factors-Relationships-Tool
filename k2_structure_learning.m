function [DAG, Scores] = k2_structure_learning(LGObj, Order, MaxParents)
    d = length(Order);
    DAG = zeros(d);
    Scores = zeros(1, d);

    for p = 1:d
        i = Order(p);
        Parent = zeros(d,1);
        Pold = GClosedFun(LGObj, i, find(Parent));
        LocalMax = Pold;
        OKToProceed = true;

        while OKToProceed && sum(Parent) < MaxParents
            BestCandidate = -1;
            for q = 1:p-1
                j = Order(q);
                if Parent(j) == 0
                    Parent(j) = 1;
                    NewScore = GClosedFun(LGObj, i, find(Parent));
                    Parent(j) = 0;
                    if NewScore > LocalMax
                        LocalMax = NewScore;
                        BestCandidate = j;
                    end
                end
            end

            if BestCandidate ~= -1
                Parent(BestCandidate) = 1;
                DAG(BestCandidate, i) = 1;
                Pold = LocalMax;
            else
                OKToProceed = false;
            end
        end
        Scores(i) = Pold;
    end
end
