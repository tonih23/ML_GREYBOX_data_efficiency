% function param_out = fes_safety(param)
% param_out = param;
% for i = 1:size(param.velec,2)
%     P = param.velec(i);
%     m = ones(size(P.cathode))*param.amp_max;
%     param_out.velec(i).amp = min(P.amp, m);
% end
function param_out = fes_safety(param_in)
    % Maximum allowable amplitude
    m = param_in.amp_max;
    
    % Initialize output parameter
    param_out = param_in;
    
    % Loop over all elements in velec
    for i = 1:length(param_in.velec)
        % Ensure the amplitude does not exceed the safety limit
        param_out.velec(i).amp = min(param_in.velec(i).amp, m * ones(size(param_in.velec(i).amp)));
    end
end