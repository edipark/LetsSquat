function [theta_trunk_deg, theta_Femur_i_deg, yi, yf, qi_deg] = ...
    solveBarY_fixedTrunkFromFinal( ...
        Femur, Tibia, Body, Foot, l, ...
        theta_Femur_f_deg, theta_Tibia_f_deg, theta_Tibia_i_deg)

% ---------------------------------------------------------
% solveBarY_fixedTrunkFromFinal
%
% 입력:
%   Femur : 허벅지 길이 [m]
%   Tibia : 정강이 길이 [m]
%   Body  : 상체 길이 [m]
%   Foot  : 발 길이 [m]
%   l     : 상체에서 bar 위치 비율 (HighBar: 0.7084, LowBar: 0.6429)
%
%   theta_Femur_f_deg : final Femur 절대각 (deg)   (예: 180)
%   theta_Tibia_f_deg : final Tibia 절대각 (deg)   (예: 51.27)
%   theta_Tibia_i_deg : initial Tibia 절대각 (deg) (예: 80)
%
% 좌표계:
%   - 발목(ankle)이 (0,0)
%   - 발 중앙 x좌표 = Foot/6
%   - Bar는 항상 x = Foot/6 위에서 수직 직선운동
%
% 출력:
%   theta_trunk_deg    : 상체 절대각 (deg), initial/final 공통
%   theta_Femur_i_deg  : initial Femur 절대각 (deg)
%   yi                 : initial 바 y좌표
%   yf                 : final   바 y좌표
%   qi_deg             : [q1i q2i q3i] (deg, 아래 정의)
%
%   q1i = 지면–정강이 상대각           = theta_Tibia_i_deg
%   q2i = 정강이–허벅지 상대각         = theta_Tibia_i_deg + theta_Femur_i_deg
%   q3i = 허벅지–상체 상대각           = theta_Tibia_i_deg + theta_Femur_i_deg + theta_trunk_deg
% ---------------------------------------------------------

    % 발 중앙 x좌표
    x_center = Foot / 6;

    % ===== 1) Final posture에서 trunk 각도 먼저 구하기 =====
    t_Tibia_f = deg2rad(theta_Tibia_f_deg);   % Tibia final (rad)
    t_Femur_f = deg2rad(theta_Femur_f_deg);   % Femur final (rad)

    % x_bar = Tibia*cos(t_Tibia_f) + Femur*cos(t_Femur_f) + l*Body*cos(t_trunk) = x_center
    rhs_trunk = ( ...
        x_center ...
      - Tibia * cos(t_Tibia_f) ...
      - Femur * cos(t_Femur_f) ...
      ) / (l * Body);

    if rhs_trunk < -1 || rhs_trunk > 1
        error("No feasible trunk angle: cos(theta_trunk) = %.4f (out of [-1,1])", rhs_trunk);
    end

    t_trunk         = acos(rhs_trunk);      % rad
    theta_trunk_deg = rad2deg(t_trunk);     % deg

    % ===== 2) Final posture에서 바 y좌표 =====
    y_knee_f = Tibia * sin(t_Tibia_f);
    y_hip_f  = y_knee_f + Femur * sin(t_Femur_f);
    yf       = y_hip_f  + l * Body * sin(t_trunk);

    % ===== 3) Initial posture에서 Femur 각도 구하기 =====
    t_Tibia_i = deg2rad(theta_Tibia_i_deg);  % Tibia initial (rad)

    % x_bar = Tibia*cos(t_Tibia_i) + Femur*cos(t_Femur_i) + l*Body*cos(t_trunk) = x_center
    rhs_Femur_i = ( ...
        x_center ...
      - Tibia * cos(t_Tibia_i) ...
      - l * Body * cos(t_trunk) ...
      ) / Femur;

    if rhs_Femur_i < -1 || rhs_Femur_i > 1
        error("No feasible initial Femur angle: cos(theta_Femur_i) = %.4f (out of [-1,1])", rhs_Femur_i);
    end

    t_Femur_i         = acos(rhs_Femur_i);      % rad
    theta_Femur_i_deg = rad2deg(t_Femur_i);     % deg

    % ===== 4) Initial posture에서 바 y좌표 =====
    y_knee_i = Tibia * sin(t_Tibia_i);
    y_hip_i  = y_knee_i + Femur * sin(t_Femur_i);
    yi       = y_hip_i  + l * Body * sin(t_trunk);

    % ===== 5) 상대각 qi (deg) - 네가 정의한 방식대로 =====
    q1i = theta_Tibia_i_deg;
    q2i = theta_Femur_i_deg - theta_Tibia_i_deg;
    q3i = theta_trunk_deg   - theta_Femur_i_deg;

    qi_deg = [q1i, q2i, q3i];

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Command Example %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Femur = 0.4703;
% Tibia = 0.3691;
% Body  = 0.9076;
% Foot  = 0.26;
% l = 0.6429;
% 
% theta_Femur_f_deg = 180;
% theta_Tibia_f_deg = 51.27;
% theta_Tibia_i_deg = 80;
% 
% [theta_trunk_deg, theta_Femur_i_deg, yi, yf, qi_deg] = ...
% solveBarY_fixedTrunkFromFinal( ...
%         Femur, Tibia, Body, Foot, l, ...
%         theta_Femur_f_deg, theta_Tibia_f_deg, theta_Tibia_i_deg)

end