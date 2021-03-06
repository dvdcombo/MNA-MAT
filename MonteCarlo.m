%%Delete previously run simulation results, if any
if(exist('Results.txt'))
    delete('Results.txt');
elseif(exist('Results.xls'))
    delete('Results.xls');
    if(exist('MC_values_ode.txt'))
        delete('MC_values_ode.txt');
    end
    delete('Voltages_graph.fig');
    if(exist('Currents_graph.fig'))
        delete('Currents_graph.fig');
    end
end
%%------------------------------------------------------------
prompt='Enter the file name - ';
fname=input(prompt,'s');
runs = input('Enter the number of runs to be performed : ');
disp('-----------------------------------------------------------------------------');
for i_i=1:runs
    disp(['RUN ' num2str(i_i)]);
    fileID1=fopen('Element_indep.txt','wt+'); %Create an empty text file for passive elements and independent sources
    fileID2=fopen('VCVS.txt','wt+'); %Create an empty text file for voltage controlled voltage sources
    fileID3=fopen('VCCS.txt','wt+'); %Create an empty text file for voltage controlled current sources
    netlist=textscan(fopen(fname),'%s %s %s %s %s %s');
    %%-----------------------------------------------------------------------------
    %Initialize
    num_Elements=0; %Number of passive elements
    num_V=0; %Number of independent voltage sources
    num_I=0; %Number of independent current sources
    num_Nodes=0; %Number of nodes, excluding ground (node 0)
    num_VCVS=0; %Number of voltage controlled voltage sources
    num_VCCS=0; %Number of voltage controlled current sources
    num_R=0; %Number of resistors
    num_L=0; %Number of inductors
    num_C=0; %Number of capacitors
    %%-----------------------------------------------------------------------------
    for i=1:length(netlist{1})
        s=netlist{1}{i};
        switch(s(1))
            case{'V','I','R','L','C'} %For independent sources and passive elements
                fprintf(fileID1,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                    netlist{3}{i} ' ' netlist{4}{i} '\n']);
            case{'E'} %For voltage controlled voltage sources
                fprintf(fileID2,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                    netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} ' ' ...
                    netlist{6}{i} '\n']);
            case{'G'} %For voltage controlled current sources
                fprintf(fileID3,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                    netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} ' ' ...
                    netlist{6}{i} '\n']);
        end
    end
    %%--------------------------------------------------------------------------
    %%Read the data from the newly created 'Element_indep.txt' text file
    [Name,N1,N2,value]=textread('Element_indep.txt','%s %s %s %s');
    for i=1:length(Name)
        switch(Name{i}(1))
            case{'R'}
                num_Elements=num_Elements+1;
                Element(num_Elements).Name=Name{i};
                Element(num_Elements).Node1=str2num(N1{i});
                Element(num_Elements).Node2=str2num(N2{i});
                Element(num_Elements).Value=str2double(value{i});
                num_R=num_R+1;
                if((i_i==1)&&(num_R==1)) %If first run, and first resistor parsed - obtain distribution type and associated properties from user
                    dist_R=input('Enter the distribution to be used for resistors :-\n 1. Gaussian (Normal)\n 2. Uniform (Rectangular)\n');
                    if dist_R==1 %Normal distribution
                        SD_R=input('Enter the standard deviation (in %) for resistor Gaussian distribution : ');
                    else  %Uniform distribution
                        w_R=input('Enter the window size (in %) for resistor Uniform distribution : ');
                    end
                end
                if dist_R == 1   %Gaussian distribution
                    if(SD_R>=0)
                        SD_element = SD_R * Element(num_Elements).Value / 100;
                        %Create a normal distribution object with mean = specified element value, and sigma = specified standard deviation
                        pd_Element=makedist('Normal','mu',Element(num_Elements).Value,...
                            'sigma',SD_element);
                        r_Element=random(pd_Element);
                        Element(num_Elements).Value=r_Element;
                    end
                else        %Uniform distribution
                    if(w_R>0)
                        a = Element(num_Elements).Value - (Element(num_Elements).Value)*w_R/100;
                        b = Element(num_Elements).Value + (Element(num_Elements).Value)*w_R/100;
                        step_Element=(b-a)/(1000-1);  %Step size for creating uniform array of 1000 values
                        array = a:step_Element:b;
                        [m, n] = size(array);
                        k = randi(n,1);
                        Element(num_Elements).Value = array(k);
                    end
                end
            case{'C'}
                num_Elements=num_Elements+1;
                Element(num_Elements).Name=Name{i};
                Element(num_Elements).Node1=str2num(N1{i});
                Element(num_Elements).Node2=str2num(N2{i});
                Element(num_Elements).Value=str2double(value{i});
                num_C=num_C+1;
                if((i_i==1)&&(num_C==1)) %If first run, and first capacitor parsed - obtain distribution type and associated properties from user
                    dist_C=input('Enter the distribution to be used for capacitors :-\n 1. Gaussian (Normal)\n 2. Uniform (Rectangular)\n');
                    if dist_C==1 %Normal distribution
                        SD_C=input('Enter the standard deviation (in %) for capacitor Gaussian distribution : ');
                    else  %Uniform distribution
                        w_C=input('Enter the window size (in %) for capacitor Uniform distribution : ');
                    end
                end
                if dist_C == 1   %Gaussian distribution
                    if(SD_C>=0)
                        SD_element = SD_C * Element(num_Elements).Value / 100;
                        %Create a normal distribution object with mean = specified element value, and sigma = specified standard deviation
                        pd_Element=makedist('Normal','mu',Element(num_Elements).Value,...
                            'sigma',SD_element);
                        r_Element=random(pd_Element);
                        Element(num_Elements).Value=r_Element;
                    end
                else        %Uniform distribution
                    if(w_C>0)
                        a = Element(num_Elements).Value - (Element(num_Elements).Value)*w_C/100;
                        b = Element(num_Elements).Value + (Element(num_Elements).Value)*w_C/100;
                        step_Element=(b-a)/(1000-1);  %Step size for creating uniform array of 1000 values
                        array = a:step_Element:b;
                        [m, n] = size(array);
                        k = randi(n,1);
                        Element(num_Elements).Value = array(k);
                    end
                end
            case{'L'}
                num_Elements=num_Elements+1;
                Element(num_Elements).Name=Name{i};
                Element(num_Elements).Node1=str2num(N1{i});
                Element(num_Elements).Node2=str2num(N2{i});
                Element(num_Elements).Value=str2double(value{i});
                num_L=num_L+1;
                if((i_i==1)&&(num_L==1)) %If first run, and first inductor parsed - obtain distribution type and associated properties from user
                    dist_L=input('Enter the distribution to be used for inductors :-\n 1. Gaussian (Normal)\n 2. Uniform (Rectangular)\n');
                    if dist_L==1 %Normal distribution
                        SD_L=input('Enter the standard deviation (in %) for inductor Gaussian distribution : ');
                    else  %Uniform distribution
                        w_L=input('Enter the window size (in %) for inductor Uniform distribution : ');
                    end
                end
                if dist_L == 1   %Gaussian distribution
                    if(SD_L>=0)
                        SD_element = SD_L * Element(num_Elements).Value / 100;
                        %Create a normal distribution object with mean = specified element value, and sigma = specified standard deviation
                        pd_Element=makedist('Normal','mu',Element(num_Elements).Value,...
                            'sigma',SD_element);
                        r_Element=random(pd_Element);
                        Element(num_Elements).Value=r_Element;
                    end
                else        %Uniform distribution
                    if(w_L>0)
                        a = Element(num_Elements).Value - (Element(num_Elements).Value)*w_L/100;
                        b = Element(num_Elements).Value + (Element(num_Elements).Value)*w_L/100;
                        step_Element=(b-a)/(1000-1);  %Step size for creating uniform array of 1000 values
                        array = a:step_Element:b;
                        [m, n] = size(array);
                        k = randi(n,1);
                        Element(num_Elements).Value = array(k);
                    end
                end
            case{'V'}
                num_V=num_V+1;
                Volt_source(num_V).Name=Name{i};
                Volt_source(num_V).Node1=str2num(N1{i});
                Volt_source(num_V).Node2=str2num(N2{i});
                Volt_source(num_V).Value=str2double(value{i});
                
            case{'I'}
                num_I=num_I+1;
                Current_source(num_I).Name=Name{i};
                Current_source(num_I).Node1=str2num(N1{i});
                Current_source(num_I).Node2=str2num(N2{i});
                Current_source(num_I).Value=str2double(value{i});
                
        end
        num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
    end
    %%---------------------------------------------------------------------------
    %%Read the data from the newly created 'VCVS.txt' text file
    [Name,N1,N2,NC1,NC2,Gain]=textread('VCVS.txt','%s %s %s %s %s %s');
    num_VCVS=length(Name);
    for i=1:num_VCVS
        VCVS(i).Name=Name{i};
        VCVS(i).N1=str2num(N1{i});
        VCVS(i).N2=str2num(N2{i});
        VCVS(i).NC1=str2num(NC1{i});
        VCVS(i).NC2=str2num(NC2{i});
        VCVS(i).Gain=str2double(Gain{i});
        num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
    end
    %%---------------------------------------------------------------------------
    %%Read the data from the newly created 'VCCS.txt' text file
    [Name,N1,N2,NC1,NC2,Transconductance]=textread('VCCS.txt','%s %s %s %s %s %s');
    num_VCCS=length(Name);
    for i=1:num_VCCS
        VCCS(i).Name=Name{i};
        VCCS(i).N1=str2num(N1{i});
        VCCS(i).N2=str2num(N2{i});
        VCCS(i).NC1=str2num(NC1{i});
        VCCS(i).NC2=str2num(NC2{i});
        VCCS(i).Transconductance=str2double(Transconductance{i});
        num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
    end
    %%---------------------------------------------------------------------------
    %%Close the no longer required text files and then delete them
    fclose(fileID1);
    fclose(fileID2);
    fclose(fileID3);
    delete('Element_indep.txt');
    delete('VCVS.txt');
    delete('VCCS.txt');
    %%---------------------------------------------------------------------------
    %%Create the variables for node voltages and currents through voltage sources
    variables='syms';
    for i=1:num_Nodes
        variables=[variables ' ' ['v_' num2str(i)]];
    end
    for i=1:num_V
        variables=[variables ' ' ['i_' Volt_source(i).Name]];
    end
    for i=1:num_VCVS
        variables=[variables ' ' ['i_' VCVS(i).Name]];
    end
    eval(variables);
    %%---------------------------------------------------------------------------
    %%Create the equations for the independent voltage sources and apply KCL at the nodes
    node_equation=cell(num_Nodes,1);
    volt_equation=cell(num_V,1);
    for i=1:num_V
        switch((Volt_source(i).Node1==0)||(Volt_source(i).Node2==0))
            %One of the terminals of voltage source is grounded
            case{1}
                if(Volt_source(i).Node1==0)
                    volt=['v_' num2str(Volt_source(i).Node2) '=' '-' num2str(Volt_source(i).Value)];
                    node_equation{Volt_source(i).Node2}=[node_equation{Volt_source(i).Node2}...
                        '-' 'i_' Volt_source(i).Name];
                else
                    volt=['v_' num2str(Volt_source(i).Node1) '='  num2str(Volt_source(i).Value)];
                    node_equation{Volt_source(i).Node1}=[node_equation{Volt_source(i).Node1}...
                        '+' 'i_' Volt_source(i).Name];
                end
                volt_equation{i}=volt;
            case{0}
                volt=['v_' num2str(Volt_source(i).Node1) '-' ...
                    'v_' num2str(Volt_source(i).Node2) '=' num2str(Volt_source(i).Value)];
                volt_equation{i}=volt;
                node_equation{Volt_source(i).Node1}=[node_equation{Volt_source(i).Node1}...
                    '+' 'i_' Volt_source(i).Name];
                node_equation{Volt_source(i).Node2}=[node_equation{Volt_source(i).Node2}...
                    '-' 'i_' Volt_source(i).Name];
        end
    end
    %%---------------------------------------------------------------------------
    %%Create the equations for the voltage controlled voltage sources and apply KCL at the nodes
    VCVS_equation=cell(num_VCVS,1);
    for i=1:num_VCVS
        switch((VCVS(i).N1==0)|(VCVS(i).N2==0))
            case{1}
                if(VCVS(i).N1==0)
                    switch((VCVS(i).NC1==0)|(VCVS(i).NC2==0))
                        case{1}
                            if(VCVS(i).NC1==0)
                                volt=['-v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                                    '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                            else
                                volt=['-v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                                    '*' '(' '+' 'v_' num2str(VCVS(i).NC1) ')'];
                            end
                        case{0}
                            volt=['-v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
                    end
                    node_equation{VCVS(i).N2}=[node_equation{VCVS(i).N2} '-' 'i_' VCVS(i).Name];
                else
                    switch((VCVS(i).NC1==0)|(VCVS(i).NC2==0))
                        case{1}
                            if(VCVS(i).NC1==0)
                                volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                                    '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                            else
                                volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                                    '*' '(' '+' 'v_' num2str(VCVS(i).NC1) ')'];
                            end
                        case{0}
                            volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
                    end
                    node_equation{VCVS(i).N1}=[node_equation{VCVS(i).N1} '+' 'i_' VCVS(i).Name];
                end
            case{0}
                switch((VCVS(i).NC1==0)|(VCVS(i).NC2==0))
                    case{1}
                        if(VCVS(i).NC1==0)
                            volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                                num2str(VCVS(i).Gain) '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                        else
                            volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                                num2str(VCVS(i).Gain) '*' '(' '+' 'v_' num2str(VCVS(i).NC1) ')'];
                        end
                    case{0}
                        volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                            num2str(VCVS(i).Gain) '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
                end
                node_equation{VCVS(i).N1}=[node_equation{VCVS(i).N1} '+' 'i_' VCVS(i).Name];
                node_equation{VCVS(i).N2}=[node_equation{VCVS(i).N2} '-' 'i_' VCVS(i).Name];
        end
        VCVS_equation{i}=volt;
    end
    %----------------------------------------------------------------------------
    solver_flag=0; %A flag used for deciding which solver to finally use
    %solver_flag=0 => Purely resistive circuit, use solve for the equations
    %solver_flag=1 => RC, RL or RLC circuit, use ode15i for the equations
    %----------------------------------------------------------------------------
    %%Add each elemental current using KCL to corresponding node equation
    for i=1:num_Elements
        switch(Element(i).Name(1))
            case{'R'}
                switch((Element(i).Node1==0)||(Element(i).Node2==0))
                    case{0}
                        node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} '+' '(' ...
                            'v_' num2str(Element(i).Node2) '-' 'v_' ...
                            num2str(Element(i).Node1) ')' '/' num2str(Element(i).Value)];
                        node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} '+' '(' ...
                            'v_' num2str(Element(i).Node1) '-' 'v_' ...
                            num2str(Element(i).Node2) ')' '/' num2str(Element(i).Value)];
                    case{1}
                        if(Element(i).Node1==0)
                            node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                                '-'   'v_' num2str(Element(i).Node2) '/' num2str(Element(i).Value)];
                        else
                            node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                                '-'   'v_' num2str(Element(i).Node1) '/' num2str(Element(i).Value)];
                        end
                end
            case{'C'}
                if(solver_flag==0) %If solver_flag is still 0, this is the first non-resistive element in Element netlist
                    solver_flag=1;
                end
                switch((Element(i).Node1==0)||(Element(i).Node2==0))
                    case{0}
                        node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                            '+' num2str(Element(i).Value) '*' '(vp(' num2str(Element(i).Node2) ')' ...
                            '-' 'vp(' num2str(Element(i).Node1) '))'];
                        node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                            '+' num2str(Element(i).Value) '*' '(vp(' num2str(Element(i).Node1) ')' ...
                            '-' 'vp(' num2str(Element(i).Node2) '))'];
                    case{1}
                        if(Element(i).Node1==0)
                            node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                                '-' num2str(Element(i).Value) '*' 'vp(' num2str(Element(i).Node2) ')'];
                        else
                            node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                                '-' num2str(Element(i).Value) '*' 'vp(' num2str(Element(i).Node1) ')'];
                        end
                end
            case{'L'}
                if(solver_flag==0) %If solver_flag is still 0, this is the first non-resistive element in Element netlist
                    solver_flag=1;
                end
        end
    end
    %%--------------------------------------------------------------------------
    %%Add the independent current sources to the node equations
    for i=1:num_I
        switch((Current_source(i).Node1==0)||(Current_source(i).Node2==0))
            case{1}
                if(Current_source(i).Node1==0)
                    node_equation{Current_source(i).Node2}=[node_equation{Current_source(i).Node2}...
                        '+' num2str(Current_source(i).Value)];
                else
                    node_equation{Current_source(i).Node1}=[node_equation{Current_source(i).Node1}...
                        '-' num2str(Current_source(i).Value)];
                end
            case{0}
                node_equation{Current_source(i).Node1}=[node_equation{Current_source(i).Node1}...
                    '-' num2str(Current_source(i).Value)];
                node_equation{Current_source(i).Node2}=[node_equation{Current_source(i).Node2}...
                    '+' num2str(Current_source(i).Value)];
        end
    end
    %%--------------------------------------------------------------------------
    %%Finally, add the voltage controlled current sources to the node equations
    for i=1:num_VCCS
        switch((VCCS(i).N1==0)|(VCCS(i).N2==0))
            case{1}
                if(VCCS(i).N1==0)
                    switch((VCCS(i).NC1==0)|(VCCS(i).NC2==0))
                        case{1}
                            if(VCCS(i).NC1==0)
                                node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                    num2str(VCCS(i).Transconductance) '*' '(' '-v_' num2str(VCCS(i).NC2) ')'];
                            else
                                node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                    num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                            end
                        case{0}
                            node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                                'v_' num2str(VCCS(i).NC2) ')'];
                    end
                else
                    switch((VCCS(i).NC1==0)|(VCCS(i).NC2==0))
                        case{1}
                            if(VCCS(i).NC1==0)
                                node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                    num2str(VCCS(i).Transconductance) '*' '(' '-v_' num2str(VCCS(i).NC2) ')'];
                            else
                                node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                    num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                            end
                        case{0}
                            node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ...
                                '-' 'v_' num2str(VCCS(i).NC2) ')'];
                    end
                end
            case{0}
                switch((VCCS(i).NC1==0)|(VCCS(i).NC2==0))
                    case{1}
                        if(VCCS(i).NC1==0)
                            node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                num2str(VCCS(i).Transconductance) '*' '(' '-v_' num2str(VCCS(i).NC2) ')'];
                            node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                num2str(VCCS(i).Transconductance) '*' '(' '-v_' num2str(VCCS(i).NC2) ')'];
                        else
                            node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                            node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                        end
                    case{0}
                        node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                            'v_' num2str(VCCS(i).NC2) ')'];
                        node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                            'v_' num2str(VCCS(i).NC2) ')'];
                end
        end
    end
    %%--------------------------------------------------------------------------
    %%If solver_flag=0 (purely resistive circuit), add the RHS('=0') to each
    %%nodal KCL equation and to each VCVS equation
    if(solver_flag==0)
        for i=1:length(node_equation)
            node_equation{i}=[node_equation{i} '=' '0'];
        end
        for i=1:length(VCVS_equation)
            VCVS_equation{i}=[VCVS_equation{i} '=' '0'];
        end
        %%Else if solver_flag=1 (RC,RL or RLC circuit),do not add the RHS ('=0')
        %%to each nodal KCL equation and to each VCVS equation, replace the terms
        %%v_1,v_2,... in LHS of the equations with v(1),v(2),... respectively,
        %%also replace the independent voltage source current terms with v(num_Nodes+j) (j=1:num_V)
        %%and the VCVS current terms with v(num_Nodes+num_V+j) (j=1:num_VCVS)
    elseif(solver_flag==1)
        for i=1:num_Nodes %For each nodal KCL equation (only LHS)
            for j=1:num_Nodes
                node_equation{i}=strrep(node_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
            end
        end
        for i=1:num_V %For each independent voltage source equation
            for j=1:num_Nodes
                volt_equation{i}=strrep(volt_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
            end
        end
        for i=1:num_Nodes %For each nodal KCL equation (only LHS)
            for j=1:num_V
                node_equation{i}=strrep(node_equation{i},['i_' Volt_source(j).Name],['v(' num2str(num_Nodes+j) ')']);
            end
            for j=1:num_VCVS
                node_equation{i}=strrep(node_equation{i},['i_' VCVS(j).Name],['v(' num2str(num_Nodes+num_V+j) ')']);
            end
        end
        for i=1:num_VCVS %For each VCVS equation
            for j=1:num_Nodes
                VCVS_equation{i}=strrep(VCVS_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
            end
        end
        %Modify the independent voltage source equations
        for i=1:num_V
            volt_equation{i}=strrep(volt_equation{i},'=','-');
        end
    end
    %%--------------------------------------------------------------------------
    eqn=cell(num_Nodes+num_V+num_VCVS,1);
    for i=1:num_Nodes
        eqn{i}=sym(node_equation{i});
    end
    for i=1:num_V
        eqn{num_Nodes+i}=sym(volt_equation{i});
    end
    for i=1:num_VCVS
        eqn{num_Nodes+num_V+i}=sym(VCVS_equation{i});
    end
    %%--------------------------------------------------------------------------
    switch(solver_flag)
        case{0}
            %%If circuit is a purely resistive circuit, use solve
            
            %Create matrix of variables to be solved
            var_string=['var=[' variables(6:end) ']'];
            eval(var_string);
            %----------------------------------------------
            %Create the symbolic variables for the equations
            equations='syms';
            for i=1:(num_Nodes+num_V+num_VCVS)
                equations=[equations ' ' ['eqn' num2str(i)]];
            end
            eval(equations);
            %----------------------------------------------
            %Create a matrix 'eqn_solve' for the equation symbolic variables
            intermediate_string=['eqn_solve=[' equations(6:end) ']'];
            eval(intermediate_string);
            %----------------------------------------------
            %Assign the equation symbolic variables with the corresponding equations
            for i=1:(num_Nodes+num_V+num_VCVS)
                eqn_string=['eqn' num2str(i) '=' 'eqn{' num2str(i) '}'];
                eval(eqn_string);
            end
            %----------------------------------------------
            %Solve the linear equations using solve
            sol=solve(eval(eqn_solve),var);
            %Note :- We use eval(eqn_solve) to substitute the equation associated with
            %each equation symbolic variable
            %----------------------------------------------
            %Write the node voltages and voltage source currents to the
            %newly created Results.txt text file
            if(i_i==1) %If first run, create empty text file Results.txt and write date and time along with file name and distribution
                F=fopen('Results.txt','wt+');
                date=datetime('now');
                date_string=datestr(date);
                fprintf(F,date_string);
                fprintf(F,'\n');
                fprintf(F,['File name : ' fname]);
                fprintf(F,'\n');
                if(dist_R==1)
                    fprintf(F,'Resistor Distribution : Normal');
                    fprintf(F,'\n');
                    fprintf(F,['Resistor Standard deviation in %% : ' num2str(SD_R)]);
                    fprintf(F,'\n');
                else
                    fprintf(F,'Resistor Distribution : Uniform');
                    fprintf(F,'\n');
                    fprintf(F,['Resistor Window size in %% : ' num2str(w_R)]);
                    fprintf(F,'\n');
                end
                fprintf(F,['Number of runs : ' num2str(runs)]);
                fprintf(F,'\n');
                fprintf(F,'----------------------------------------------------------------------- \n');
            end
            fprintf(F,['RUN ' num2str(i_i)]);
            fprintf(F,'\n \n');
            it = 1;
            for j=1:num_Elements
                fprintf(F,Element(j).Name);
                fprintf(F,' = ');
                fprintf(F,[num2str(Element(j).Value) '\n']);
            end
            fprintf(F,'--------------------------------------------------------------------------- \n');
            fprintf(F,'NODE VOLTAGES \n');
            for i=1:num_Nodes
                fprintf(F,['v_' num2str(i) ' = ']);
                fprintf(F,num2str(eval(eval(['sol.v_' num2str(i)]))));
                fprintf(F, '\n');
                table(i_i, it) = eval(eval(['sol.v_' num2str(i)]));
                it = it +1;
                
            end
            fprintf(F,'------------------------------------------------------------------- \n');
            if(num_V~=0)
                fprintf(F,'CURRENTS THROUGH INDEPENDENT VOLTAGE SOURCES (NEGATIVE TO POSITIVE TERMINAL) \n');
                for i=1:num_V
                    fprintf(F,['i_' Volt_source(i).Name ' = ']);
                    fprintf(F,num2str(eval(eval(['sol.i_' Volt_source(i).Name]))));
                    fprintf(F, '\n');
                    table(i_i, it) = eval(eval(['sol.i_' Volt_source(i).Name]));
                    it = it + 1;
                end
                fprintf(F,'------------------------------------------------------------------- \n');
            end
            if(num_VCVS~=0)
                fprintf(F,'CURRENTS THROUGH VOLTAGE CONTROLLED VOLTAGE SOURCES (NEGATIVE TO POSITIVE TERMINAL) \n');
                for i=1:num_VCVS
                    fprintf(F,['i_' VCVS(i).Name ' = ']);
                    fprintf(F,num2str(eval(eval(['sol.i_' VCVS(i).Name]))));
                    fprintf(F, '\n');
                    table(i_i, it) = eval(eval(['sol.i_' VCVS(i).Name]));
                    it = it + 1;
                end
                fprintf(F,'------------------------------------------------------------------- \n');
            end
            if(i_i==runs) %If at last run, display Results.txt file then close it, and display the node voltages and currents at each run
                type('Results.txt');
                fclose(F);
                [m,n] = size(table);
                for l=1:num_Nodes   %Plot each node voltage recorded at each run
                    x = 1:m;
                    figure;
                    quant = table(:,l);
                    stem(x,quant);
                    xlabel('RUN');
                    ylabel(['v\_' num2str(l)]);
                end
                for l=1:num_V  %Plot each independent voltage source current recorded at each run
                    x = 1:m;
                    figure;
                    quant = table(:,(num_Nodes+l));
                    stem(x,quant);
                    xlabel('RUN');
                    ylabel(['i\_' Volt_source(l).Name]);
                end
                for l=1:num_VCVS  %Plot each VCVS current recorded at each run
                    x=1:m;
                    figure;
                    quant = table(:,(num_Nodes+num_V+l));
                    stem(x,quant);
                    xlabel('RUN');
                    ylabel(['i\_' VCVS(l).Name]);
                end
            end
            
            
            %%--------------------------------------------------------------------------
        case{1}
            %Convert the equations to a form suitable for daeFunction
            variables='syms';
            for i=1:(num_Nodes+num_V+num_VCVS)
                variables=[variables ' ' 'v' num2str(i) '(t)'];
            end
            eval(variables);
            eqn_string='eqn_daeFunction=[';
            for i=1:length(eqn)
                interm_string=char(eqn{i});
                for j=1:(num_Nodes+num_V+num_VCVS)
                    interm_string=strrep(interm_string,['v(' num2str(j) ')'],['v' num2str(j) '(t)']);
                end
                for j=1:num_Nodes
                    interm_string=strrep(interm_string,['vp(' num2str(j) ')'],['diff(v' num2str(j)...
                        '(t)' ',t)']);
                end
                eqn_string=[eqn_string interm_string ','];
            end
            eqn_string=[eqn_string ']'];
            eval(eqn_string);
            %-------------------------------------------------------------------
            %Create the matrix of variables to be solved
            interm_string='variables=[';
            for i=1:(num_Nodes+num_V+num_VCVS)
                interm_string=[interm_string 'v' num2str(i) '(t)' ','];
            end
            interm_string=[interm_string ']'];
            eval(interm_string);
            %-------------------------------------------------------------------
            %Use daeFunction to create the function handle odefun
            odefun=daeFunction(eqn_daeFunction,variables);
            %-------------------------------------------------------------------
            %Use ode15i along with created function handle odefun
            v0=zeros(length(eqn_daeFunction),1); %Initial conditions for v
            vp0=zeros(length(eqn_daeFunction),1); %Initial conditions for v'
            if(i_i==1)   %If first run, obtain the simulation time tf
                fprintf('The transient analysis will be run from t=0 to t=tf');
                fprintf('\n');
                tf=input('Enter the final time value tf in seconds : ');
            end
            options=odeset('RelTol',1e-03,'AbsTol',1e-03);
            [t,v]=ode15i(odefun,[0 tf],v0,vp0,options);
            if(i_i==1) %If first run, create empty text file MC_values_ode.txt
                G=fopen('MC_values_ode.txt','wt+');
            end
            fprintf(G,['RUN ' num2str(i_i)]);
            fprintf(G,'\n \n');
            for j=1:num_Elements
                fprintf(G,[Element(j).Name ' = ' num2str(Element(j).Value)]);
                fprintf(G,'\n');
            end
            fprintf(G,'--------------------------------------------------------------------- \n');
            if(i_i==1)
                table_heading=cell(1,(1+num_Nodes+num_V+num_VCVS));
                table_heading{1}='Time';
                for j=1:num_Nodes
                    table_heading{1+j}=['v_' num2str(j)];
                end
                for j=1:num_V
                    table_heading{1+num_Nodes+j}=['i_' Volt_source(j).Name];
                end
                for j=1:num_VCVS
                    table_heading{1+num_Nodes+num_V+j}=['i_' VCVS(j).Name];
                end
            end
            T=array2table([t,v],'VariableNames',table_heading);
            if(i_i==1)
                date=datetime('now');
                date_string=datestr(date);
                warning('off');
                xlswrite('Results.xls',{date_string});
                xlswrite('Results.xls',{['File name : ' fname]},1,'A2');
                if(dist_R==1)
                    xlswrite('Results.xls',{'Resistor Distribution : Normal'},1,'A3');
                    xlswrite('Results.xls',{['Resistor SD in % : ' num2str(SD_R)]},1,'A4');
                else
                    xlswrite('Results.xls',{'Resistor Distribution : Uniform'},1,'A3');
                    xlswrite('Results.xls',{['Resistor Window size % : ' num2str(w_R)]},1,'A4');
                end
                if(dist_C==1)
                    xlswrite('Results.xls',{'Capacitor Distribution : Normal'},1,'A5');
                    xlswrite('Results.xls',{['Capacitor SD in % : ' num2str(SD_C)]},1,'A6');
                else
                    xlswrite('Results.xls',{'Capacitor Distribution : Uniform'},1,'A5');
                    xlswrite('Results.xls',{['Capacitor Window size % : ' num2str(w_C)]},1,'A6');
                end
                xlswrite('Results.xls',{['Runs : ' num2str(runs)]},1,'A7');
            end
            writetable(T,'Results.xls','Range','A9','Sheet',i_i);
            figure(1);
            plot(t,v(:,1:num_Nodes));hold on; %Plot the node voltages as a function of time
            if(i_i==1)
                legend_voltage='legend(';
            end
            for i=1:num_Nodes
                interm_string=table_heading{1+i};
                interm_string=strrep(interm_string,'_','\_');
                legend_voltage=[legend_voltage '''' interm_string ' (RUN ' num2str(i_i) ')'   '''' ','];
            end
            if(i_i==runs)
                legend_voltage(end)=')';
                eval(legend_voltage);
            end
            if((num_V~=0)||(num_VCVS~=0))
                figure(2);
                plot(t,v(:,(num_Nodes+1):end)); hold on; %Plot the current through voltage sources as a function of time
                if(i_i==1)
                    legend_current='legend(';
                end
                for i=1:num_V
                    interm_string=table_heading{1+num_Nodes+i};
                    interm_string=strrep(interm_string,'_','\_');
                    legend_current=[legend_current '''' interm_string ' (RUN ' num2str(i_i) ')' '''' ','];
                end
                for i=1:num_VCVS
                    interm_string=table_heading{1+num_Nodes+num_V+i};
                    interm_string=strrep(interm_string,'_','\_');
                    legend_current=[legend_current '''' interm_string ' (RUN ' num2str(i_i) ')' '''' ','];
                end
                if(i_i==runs)
                    legend_current(end)=')';
                    eval(legend_current);
                end
            end
            if(i_i==runs)  %If last run, display the values used at each run, and save the two graphs
                type('MC_values_ode.txt');
                fclose(G);
                figure(1);
                savefig('Voltages_graph.fig');
                if((num_V~=0)||(num_VCVS~=0))
                    figure(2);
                    savefig('Currents_graph.fig');
                end
            end
    end
end




