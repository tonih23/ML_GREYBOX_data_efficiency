% Function to compute Expected Improvement (EI)
function [mean_pred, std_pred, ei] = expected_improvement(X_query, gp_model, best_y)
    % Predict mean and variance at query points
    [mean_pred, std_pred] = predict(gp_model, X_query);
    z = (mean_pred - best_y) ./ std_pred;

    % Compute Expected Improvement
    ei = (mean_pred - best_y) .* normcdf(z) + std_pred .* normpdf(z);
end
