function y_2dot = ThreePointCentralDifference(y, h)
    n = length(y);
    
    y_2dot(:, 1) = (2*y(:, 1) - 5*y(:, 2) + 4*y(:, 3) - y(:, 4))/(h^2); % four point forward difference
    for i=2:n-1
        y_2dot(:, i) = (y(:, i-1) - 2*y(:, i) + y(:, i+1))/(h^2);
    end
    y_2dot(:, n) = (-y(:, n-3) + 4*y(:, n-2) - 5*y(:, n-1) + 2*y(:, n))/(h^2); % four point backward difference
end