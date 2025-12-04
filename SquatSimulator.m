%%% GUI Part %%%
prompt = {'Thigh(Femur) Length (m):', ...
          'Shank(Tibia) Length (m):', ...
          'Torso(Body) Length (m):', ...
          'Foot Length (m):', ...
          'Body Mass (kg):',...
          'Squat Type (high or low):', ...
          'Barbell Weight (kg):'};

dlgtitle = 'Squat Simulation Setup';

dims = [1 50];

definput = {'0.4703', '0.3691', '0.9076', '0.26', '76.9', 'high', '100'};

answer = inputdlg(prompt, dlgtitle, dims, definput);

Femur = str2double(answer{1});
Tibia = str2double(answer{2});
Body = str2double(answer{3});
Foot = str2double(answer{4});
Mass = str2double(answer{5});
Type = string(answer{6});
Barbell = str2double(answer{7});

if isempty(answer)
    error('UserInterruption');
end

%%% Configs %%%
config = [Femur, Tibia, Body, Foot, Mass]; 

if Type == "high"
    l = 0.7084;
    theta_Femur_f_deg = 190;
elseif Type == "low"
    l = 0.6429;
    theta_Femur_f_deg = 180;
end
theta_Tibia_f_deg = 51.27;
theta_Tibia_i_deg = 80;

%%% Simulation Start %%%
robot = squat_robot(config, Barbell, Type);
[Body_Angle, ~, yi, yf, ~] = solveBarY_fixedTrunkFromFinal(Femur, Tibia, Body, Foot, l, theta_Femur_f_deg, theta_Tibia_f_deg, theta_Tibia_i_deg);
[qs, vel, acc, taus, time] = squat_simulation(robot, Type, Body_Angle, yi, yf, true, true);

%%% Result %%%

max_torque = max(max(abs(taus))); 
duration = time(end);             
rom = yi - yf;                    

result_str = { ...
    sprintf('Simulation Complete!'), ...
    '---------------------------------', ...
    sprintf('Squat Type:       %s', Type), ...
    sprintf('Body Angle:       %.2f deg', Body_Angle), ...
    sprintf('Barbell Weight:   %.1f kg', Barbell), ...
    '---------------------------------', ...
    sprintf('Duration:          %.2f sec', duration), ...
    sprintf('Vertical ROM:     %.3f m', rom), ...
    sprintf('Peak Torque:      %.2f Nm', max_torque), ...
    '---------------------------------'};

msgbox(result_str, 'Simulation Report');
