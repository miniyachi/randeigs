function errors = compute_errors(lambdatrues, D)
    K = length(lambdatrues);
    n_iter = size(D,2);
    errors = zeros(K,n_iter);
    for i = 1:K
        errors(i,:) = min(abs(lambdatrues(i) - D) / abs(lambdatrues(i)));
    end
end