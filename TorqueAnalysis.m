function [qs, vel, acc, taus, time, Body_Angle] = TorqueAnalysis(config, Type, theta_Femur_f_deg ,theta_Tibia_f_deg)
    if Type == "high"
        l = 0.7084;
    elseif Type == "low"
        l = 0.6429;
    end
    theta_Tibia_i_deg = 80;
    Barbell = 100;
    % config = [0.4703, 0.3691, 0.9076, 0.26, 76.9];
    Femur = config(1);
    Tibia = config(2);
    Body = config(3);
    Foot = config(4);
    Mass = config(5);

    robot = squat_robot(config, Barbell, Type);
    [Body_Angle, ~, yi, yf, ~] = solveBarY_fixedTrunkFromFinal(Femur, Tibia, Body, Foot, l, theta_Femur_f_deg, theta_Tibia_f_deg, theta_Tibia_i_deg);
    [qs, vel, acc, taus, time] = squat_simulation(robot, Type, Body_Angle, yi, yf, false, false); % 시각화 옵션

    end