function DAG = run_causal_inference()
    % Pop-up UI for configuration
    d = dialog('Position',[300 300 400 300],'Name','Causal Inference Config');

    uicontrol('Parent',d,'Style','text','Position',[100 260 200 20],'String','Select Factor Mode');
    bg1 = uibuttongroup('Parent',d,'Position',[.3 .75 .4 .15]);
    rb1 = uicontrol(bg1,'Style','radiobutton','String','Grouped','Position',[10 10 100 20],'HandleVisibility','off');
    rb2 = uicontrol(bg1,'Style','radiobutton','String','Original','Position',[110 10 100 20],'HandleVisibility','off');

    uicontrol('Parent',d,'Style','text','Position',[100 200 200 20],'String','Select Method');
    methodMenu = uicontrol('Parent',d,'Style','popupmenu','String',{'k2','npc','expert','aggregated'},'Position',[100 170 200 25]);

    uicontrol('Parent',d,'Style','text','Position',[100 130 200 20],'String','Max Parents (K2 only)');
    maxParentsBox = uicontrol('Parent',d,'Style','edit','String','3','Position',[150 110 100 25]);

    uicontrol('Parent',d,'Style','text','Position',[100 80 200 20],'String','Alpha (NPC only)');
    alphaBox = uicontrol('Parent',d,'Style','edit','String','0.05','Position',[150 60 100 25]);

    uicontrol('Parent',d,'Position',[150 20 100 30],'String','Run','Callback','uiresume(gcbf)');
    uiwait(d);

    useGrouped = strcmp(bg1.SelectedObject.String, 'Grouped');
    method = methodMenu.String{methodMenu.Value};
    maxParents = str2double(maxParentsBox.String);
    alpha = str2double(alphaBox.String);
    close(d);

    % Load appropriate data matrix and expert links
    if useGrouped
        dataMatrix = readmatrix('MATA_D_Matrix_Grouped.xlsx');
        expertMatrix = readmatrix('Grouped_ExpertOp.xlsx');
    else
        dataMatrix = readmatrix('MATA_D_MatFormFull.xlsx');
        expertMatrix = readmatrix('Expert Links Format.xlsx');
    end

    LGObj_K2 = ConstructLGObj_K2(dataMatrix);
    LGObj_NPC = ConstructLGObj_NPC(dataMatrix);

    switch lower(method)
        case 'k2'
            Order = entropy_based_ordering(dataMatrix);
            [DAG, ~] = k2_structure_learning(LGObj_K2, Order, maxParents);

        case 'npc'
            DAG = npc_structure_learning(LGObj_NPC, alpha);

        case 'expert'
            DAG = expertMatrix;

        case 'aggregated'
            Order = entropy_based_ordering(dataMatrix);
            [DAG_K2, ~] = k2_structure_learning(LGObj_K2, Order, maxParents);
            DAG_NPC = npc_structure_learning(LGObj_NPC, alpha);
            DAG_Expert = expertMatrix;
            DAG = (DAG_K2 + DAG_NPC + DAG_Expert) >= 2;

        otherwise
            error('Unknown method: choose k2, npc, expert, or aggregated');
    end

    G = digraph(DAG);
    figure;
    plot(G);
    title(['Causal DAG - ', upper(method), ' | ', ternary(useGrouped, 'Grouped', 'Original'), ' Factors']);
end

function label = ternary(condition, trueLabel, falseLabel)
    if condition
        label = trueLabel;
    else
        label = falseLabel;
    end
end
