function y_dot = TwoPointCentralDifference(y, h)
    n = length(y);
    
    y_dot(:, 1) = (-3*y(:, 1) + 4*y(:, 2) - y(:, 3))/(2*h); % Three point forward difference for initial diff.
    for i=2:n-1
        y_dot(:, i) = (y(:, i+1) - y(:, i-1))/(2*h);
    end
    y_dot(:, n) = (y(:, n-2) - 4*y(:, n-1) + 3*y(:, n))/(2*h); % Three point backward difference for last diff.
end