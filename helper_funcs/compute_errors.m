function errors = compute_errors(lambdatrues, diagD)
    K = length(lambdatrues);
    errors = zeros(K,1);
    for i =1:K
        errors(i,1) = min(abs(lambdatrues(i) - diagD) / abs(lambdatrues(i)));
    end
end