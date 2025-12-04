function [kneeInt, hipInt, trunkAng] = ...
    plotLocalTorqueHeatmapUI(config, Type, theta_Femur_center, theta_Tibia_center)
    
    % --- Parameters ---
    stepDeg  = 3;
    spanDeg  = 30;
    halfSpan = spanDeg/2;
    theta_Femur_vals = (theta_Femur_center - halfSpan) : stepDeg : (theta_Femur_center + halfSpan);
    theta_Tibia_vals = (theta_Tibia_center - halfSpan) : stepDeg : (theta_Tibia_center + halfSpan);
    nF = length(theta_Femur_vals);
    nT = length(theta_Tibia_vals);
    
    kneeInt  = NaN(nF, nT);   
    hipInt   = NaN(nF, nT);
    trunkAng = NaN(nF, nT);
    
    % --- Waitbar & Parallel Pool ---
    hWait = waitbar(0, 'Starting Parallel Pool... (This may take time)', ...
        'Name', 'Processing', ...
        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(hWait, 'canceling', 0);
    
    drawnow; 
    
    pool = gcp; 
    
    if getappdata(hWait, 'canceling')
        delete(hWait);
        error('User:Cancel', 'Simulation cancelled during initialization.');
    end
   
    D = parallel.pool.DataQueue;
    waitbar(0, hWait, 'Initializing Calculation...');
    
    totalIter = nF; 
    count = 0;
    afterEach(D, @nUpdateWaitbar);
    
    function nUpdateWaitbar(~)
        count = count + 1;
        if ~ishandle(hWait) || getappdata(hWait, 'canceling')
            error('User:Cancel', 'Simulation stopped by user.');
        else
            waitbar(count / totalIter, hWait, ...
                sprintf('Parallel Calculation... %d / %d (Rows)', count, totalIter));
        end
    end

    % --- Simulation Loop (Parfor) ---
    try
        parfor iF = 1:nF
            row_knee = NaN(1, nT);
            row_hip  = NaN(1, nT);
            row_trunk = NaN(1, nT);
            
            thF = theta_Femur_vals(iF); 
            
            for iT = 1:nT
                thT = theta_Tibia_vals(iT);
                try
                    [~, ~, ~, taus, time, Body_Angle] = ...
                        TorqueAnalysis(config, Type, thF, thT);
                    
                    kneeTau = abs(taus(2,:));
                    hipTau  = abs(taus(3,:));
                    
                    row_knee(iT)  = trapz(time, kneeTau);
                    row_hip(iT)   = trapz(time, hipTau);
                    row_trunk(iT) = Body_Angle;
                catch
                end
            end
            kneeInt(iF, :)  = row_knee;
            hipInt(iF, :)   = row_hip;
            trunkAng(iF, :) = row_trunk;
            send(D, 1); 
        end
    catch ME
        if strcmp(ME.identifier, 'User:Cancel')
            fprintf('Simulation cancelled by user.\n');
            if ishandle(hWait), delete(hWait); end
            return;
        else
            rethrow(ME);
        end
    end
    
    if ishandle(hWait), delete(hWait); end
    
    % --- Result Plotting ---
    allVals = [kneeInt(:); hipInt(:)];
    allVals = allVals(~isnan(allVals));
    if isempty(allVals), vmin=0; vmax=1; else, vmin=min(allVals); vmax=max(allVals); end
    cmap = turbo(256);
    
    figure;
    tiledlayout(1,2);
    
    % [1] Knee Heatmap
    nexttile;
    imagesc(theta_Tibia_vals, theta_Femur_vals, kneeInt);  
    set(gca,'YDir','normal'); colormap(gca, cmap); caxis([vmin vmax]); colorbar;
    xlabel('Tibia angle (deg)'); ylabel('Femur angle (deg)');
    title(sprintf('%s bar - Knee Torque Integral', Type));
    hold on;
    
    h1 = []; 
    if ~all(isnan(trunkAng(:)))
        [C1,h1] = contour(theta_Tibia_vals, theta_Femur_vals, trunkAng, ...
            'LineColor','w','LineWidth',1.6,'LineStyle','--');
        clabel(C1,h1,'Color','w','FontSize',10,'FontWeight','bold');
    end
    
    hMarker = plot(theta_Tibia_center, theta_Femur_center, ...
         'o','MarkerSize',10, ...
         'MarkerFaceColor',[1 0.4 0.7], ...
         'MarkerEdgeColor','k','LineWidth',1.3);
    
    if ~isempty(h1)
        lgd = legend([h1, hMarker], {'Body Angle', 'Current Posture'}, 'Location', 'northeast');
        set(lgd, 'Color', [0 0 0]); 
    else
        legend(hMarker, {'Current Posture'}, 'Location', 'northeast');
    end
    hold off;
    
    % [2] Hip Heatmap
    nexttile;
    imagesc(theta_Tibia_vals, theta_Femur_vals, hipInt);
    set(gca,'YDir','normal'); colormap(gca, cmap); caxis([vmin vmax]); colorbar;
    xlabel('Tibia angle (deg)'); ylabel('Femur angle (deg)');
    title(sprintf('%s bar - Hip Torque Integral', Type));
    hold on;
    
    h2 = []; 
    if ~all(isnan(trunkAng(:)))
        [C2,h2] = contour(theta_Tibia_vals, theta_Femur_vals, trunkAng, ...
            'LineColor','w','LineWidth',1.6,'LineStyle','--');
        clabel(C2,h2,'Color','w','FontSize',10,'FontWeight','bold');
    end
    
    hMarker2 = plot(theta_Tibia_center, theta_Femur_center, ...
         'o','MarkerSize',10, ...
         'MarkerFaceColor',[1 0.4 0.7], ...
         'MarkerEdgeColor','k','LineWidth',1.3);
         
    if ~isempty(h2)
        lgd2 = legend([h2, hMarker2], {'Body Angle', 'Current Posture'}, 'Location', 'northeast');
        set(lgd2, 'Color', [0 0 0]); 
    else
        legend(hMarker2, {'Current Posture'}, 'Location', 'northeast');
    end
    hold off;
end