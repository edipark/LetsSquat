function Sim2(Femur, Tibia, Body, Foot, Mass, Type, Barbell)
    %%% GUI Part %%%
    prompt = {
              'Final Thigh(Femur) Angle (degree):', ...
              'Final Shank(Tibia) Angle (degree):'};
    
    dlgtitle = 'Choose Your Trajectory';
    
    dims = [1 50];
    
    definput = {'180', '51.27'};
    
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    
    theta_Femur_f_deg = str2double(answer{1});
    theta_Tibia_f_deg = str2double(answer{2});

    
    if isempty(answer)
        error('UserInterruption');
    end
    
    %%% Configs %%%
    config = [Femur, Tibia, Body, Foot, Mass]; 
    
    if Type == "high"
        l = 0.7084;
    elseif Type == "low"
        l = 0.6429;
    end
    theta_Tibia_i_deg = 80;
    
    %%% Simulation Start %%%
    robot = squat_robot(config, Barbell, Type);
    [Body_Angle, ~, yi, yf, ~] = solveBarY_fixedTrunkFromFinal(Femur, Tibia, Body, Foot, l, theta_Femur_f_deg, theta_Tibia_f_deg, theta_Tibia_i_deg);
    [qs, vel, acc, taus, time] = squat_simulation(robot, Type, Body_Angle, yi, yf, true, true);
    
    %%% Result %%%
    
    duration = time(end);             
    rom = yi - yf;                    
    
    result_str = { ...
        sprintf('Simulation Complete!'), ...
        '---------------------------------', ...
        sprintf('Squat Type:       %s', Type), ...
        sprintf('Barbell Weight:   %.1f kg', Barbell), ...
        '---------------------------------', ...
        sprintf('Duration:          %.2f sec', duration), ...
        sprintf('Vertical ROM:     %.3f m', rom), ...
        sprintf('Body Angle:       %.2f deg', Body_Angle), ...
        '---------------------------------'};
    msgbox(result_str, 'Simulation Report');

end