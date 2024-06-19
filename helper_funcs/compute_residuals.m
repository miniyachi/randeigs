function res = compute_residuals(A, V, d)
    if isa(A, 'function_handle')
        res = vecnorm(A(V) - V .* d')'; % If A is a function handle
    else
        res = vecnorm(A * V - V .* d')'; % If A is a matrix
    end
end