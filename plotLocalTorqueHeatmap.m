function [kneeInt, hipInt, trunkAng] = ...
    plotLocalTorqueHeatmap(config, Type, theta_Femur_center, theta_Tibia_center)

    % Parameters
    stepDeg  = 3;
    spanDeg  = 30;
    halfSpan = spanDeg/2;

    theta_Femur_vals = (theta_Femur_center - halfSpan) : stepDeg : (theta_Femur_center + halfSpan);
    theta_Tibia_vals = (theta_Tibia_center - halfSpan) : stepDeg : (theta_Tibia_center + halfSpan);

    nF = length(theta_Femur_vals);
    nT = length(theta_Tibia_vals);

    kneeInt  = NaN(nF, nT);   % femur rows, tibia cols
    hipInt   = NaN(nF, nT);
    trunkAng = NaN(nF, nT);

    % Simulation Loop
    for iF = 1:nF        % femur = Y axis
        for iT = 1:nT    % tibia = X axis
            
            thF = theta_Femur_vals(iF);
            thT = theta_Tibia_vals(iT);

            try
                [qs, vel, acc, taus, time, Body_Angle] = ...
                    TorqueAnalysis(config, Type, thF, thT);

                kneeTau = abs(taus(2,:));
                hipTau  = abs(taus(3,:));

                kneeInt(iF,iT)  = trapz(time, kneeTau);
                hipInt(iF,iT)   = trapz(time, hipTau);
                trunkAng(iF,iT) = Body_Angle;

            catch
                % infeasible posture = NaN
            end
        end
    end


    % Shared Color Scale
    allVals = [kneeInt(:); hipInt(:)];
    allVals = allVals(~isnan(allVals));
    vmin = min(allVals);
    vmax = max(allVals);
    cmap = turbo(256);


    % Plot Heatmaps
    figure;
    tiledlayout(1,2);

    % Knee Heatmap
    nexttile;
    imagesc(theta_Tibia_vals, theta_Femur_vals, kneeInt);  % X=Tibia, Y=Femur
    set(gca,'YDir','normal');
    colormap(gca, cmap);
    caxis([vmin vmax]); colorbar;
    xlabel('Tibia angle (deg)');
    ylabel('Femur angle (deg)');
    title(sprintf('%s bar - Knee Torque Integral', Type));

    hold on;
    [C1,h1] = contour(theta_Tibia_vals, theta_Femur_vals, trunkAng, ...
        'LineColor','w','LineWidth',1.6,'LineStyle','--');
    clabel(C1,h1,'Color','w','FontSize',10,'FontWeight','bold');
    plot(theta_Tibia_center, theta_Femur_center, ...
         'o','MarkerSize',10, ...
         'MarkerFaceColor',[1 0.4 0.7], ...
         'MarkerEdgeColor','k','LineWidth',1.3);
    hold off;


    % Hip Heatmap
    nexttile;
    imagesc(theta_Tibia_vals, theta_Femur_vals, hipInt);
    set(gca,'YDir','normal');
    colormap(gca, cmap);
    caxis([vmin vmax]); colorbar;
    xlabel('Tibia angle (deg)');
    ylabel('Femur angle (deg)');
    title(sprintf('%s bar - Hip Torque Integral', Type));

    hold on;
    [C2,h2] = contour(theta_Tibia_vals, theta_Femur_vals, trunkAng, ...
        'LineColor','w','LineWidth',1.6,'LineStyle','--');
    clabel(C2,h2,'Color','w','FontSize',10,'FontWeight','bold');
    plot(theta_Tibia_center, theta_Femur_center, ...
         'o','MarkerSize',10, ...
         'MarkerFaceColor',[1 0.4 0.7], ...
         'MarkerEdgeColor','k','LineWidth',1.3);
    hold off;

end
