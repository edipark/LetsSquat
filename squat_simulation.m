function [qs, vel, acc, taus, time] = squat_simulation(robot, Type, Body_Angle, yi, yf, visualize, plt)
    % yi = 1.2
    % yf = 0.9
    % config = [0.4703, 0.3691, 0.9076, 0.26, 76.9];
    t = (0:0.001:0.3)';
    T = t(end);
   
    
    s_down = (1 - cos(pi * t / T)) / 2;   % 0 → 1
    s_up = flipud(s_down);
    
    s = [s_down; s_up]; 
    count = length(s);
    [n, ~ ] = size(s);
    framesPerSecond = 60;
    dur = n/framesPerSecond;
    
    h = yi-yf;
    
    y_traj = h * s;
    points = [(0.26/3)*ones(count,1), yi - y_traj, zeros(count,1)];

    q0 = homeConfiguration(robot);
    q0(2) = -2*pi/3;
    q0(3)= 2*pi/3;
    
    ndof = length(q0);
    gik = generalizedInverseKinematics('RigidBodyTree', robot,'ConstraintInputs', {'orientation','position'});
    gik.ConstraintInputs = {'orientation','position'};
    
    oc = constraintOrientationTarget('Body_Extended');
    yaw = deg2rad(Body_Angle);
    oc.TargetOrientation = eul2quat([yaw 0 0]);
    
    qs = zeros(count, ndof);
    
    qInitial = q0;
    
    for i = 1:count
        
        % --- Position constraint for toolTip ---
        pc = constraintPositionTarget('Body_Extended');
        pc.TargetPosition = points(i,:);
        
        % --- Solve generalized IK ---
        [qSol, solInfo] = gik(qInitial, oc, pc);
        
        qs(i,:) = qSol;
        qInitial = qSol;
    end
    if visualize
        showdetails(robot)
        figure
        ax = gca;
        show(robot, qs(1,:)','Parent',ax ,'Frames', 'off');
        view(2)
        ax.Projection = 'orthographic';
        hold on
        axis([-0.7 0.7 0 1.8 -0.2 0.2])
        if Type == "high"
            title_str = sprintf("Highbar Squat %2.4f^{\\circ}", Body_Angle);
        elseif Type == "low"
            title_str = sprintf("Lowbar Squat %2.4f^{\\circ}", Body_Angle);
        end 
        title(ax, title_str, 'FontSize', 10, 'FontWeight', 'bold');

        % 2D video
        if Type == "high"
            filename = sprintf('Highbar_Squat_%2.4f degree.mp4', Body_Angle);
        elseif Type == "low"
            filename = sprintf('Lowbar_Squat_%2.4f degree.mp4', Body_Angle);
        end 

        v = VideoWriter(filename, 'MPEG-4');
        v.FrameRate = framesPerSecond;                             
        open(v);
    
        r = rateControl(framesPerSecond);
        for i = 1:count
            show(robot, qs(i,:)','Parent',ax ,'PreservePlot', false, 'Frames', 'off');
            com_list = getAllCOM(robot, qs(i, :)');
            scatter3(ax, com_list(5, 1), com_list(5, 2), com_list(5, 3)+ 0.15, 40, 'filled', 'b')
            drawnow
            frame = getframe(gcf);
            writeVideo(v, frame);
            waitfor(r);
        end
        hold off
    end
    [n, ~ ] = size(qs);
    h = (dur)/n;
    qs = qs';
    vel = TwoPointCentralDifference(qs, h);
    acc = ThreePointCentralDifference(qs, h);
    taus = zeros(3, n);
    
    for i=1:n
        taus(:, i) = inverseDynamics(robot, qs(:, i), vel(:, i), acc(:, i));
    end
    time = linspace(0, dur, n);
    if plt
        figure
        tiledlayout(3, 1)
        nexttile
        plot(time, qs, 'Linewidth', 2)
        legend("Ankle", "Knee", "Hip")
        grid on
        if Type == "high"
            title_str = sprintf("Highbar Squat %2.4f degree: Angular Displacement", Body_Angle);
        elseif Type == "low"
            title_str = sprintf("Lowbar Squat %2.4f degree: Angular Displacement", Body_Angle);
        end 
        title(title_str)
        axis tight
        
        nexttile
        plot(time, vel, 'Linewidth', 2)
        legend("Ankle", "Knee", "Hip")
        grid on
        if Type == "high"
            title_str = sprintf("Highbar Squat %2.4f degree: Angular Velocity", Body_Angle);
        elseif Type == "low"
            title_str = sprintf("Lowbar Squat %2.4f degree: Angular Velocity", Body_Angle);
        end 
        title(title_str)
        axis tight
        
        nexttile
        plot(time, acc, 'Linewidth', 2)
        legend("Ankle", "Knee", "Hip")
        grid on
        if Type == "high"
            title_str = sprintf("Highbar Squat %2.4f degree: Angular Acceleration", Body_Angle);
        elseif Type == "low"
            title_str = sprintf("Lowbar Squat %2.4f degree: Angular Acceleration", Body_Angle);
        end 
        title(title_str)
        axis tight
        
        figure
        plot(time, abs(taus), 'Linewidth', 2)
        legend("Ankle", "Knee", "Hip")
        grid on
        if Type == "high"
            title_str = sprintf("Highbar Squat %2.4f degree: Joint Torque", Body_Angle);
        elseif Type == "low"
            title_str = sprintf("Lowbar Squat %2.4f degree: Joint Torque", Body_Angle);
        end 
        title(title_str)
        axis tight
        
    end
end


