function S = plant_integ(h,param)
%% Create the initial state matrix


t = 1/param.fs:1/param.fs:param.time;
numVar = h.state.getNY();
S = [];
x_dot = zeros(numVar,param.n);

for i = 1:numVar
    x_dot(i,1) = h.state.getY().get(i-1);
end

% for i = 1:param.n
%     h.state.setTime(t(i));
%     
%     %% Update state with current values  
%     for j = 1:numVar
%         h.state.updY().set(j-1, x_dot(j,i));
%     end
%     
%     %% Update the state velocity calculations
%     h.model.computeStateVariableDerivatives(h.state);
%     
%     %% Update model with control values
%     [controlVector,param,D] = h.control(h, param); 
%     h.model.setControls(h.state, controlVector);
%     
%     %% Update the derivative calculations in the state variable
%     h.model.computeStateVariableDerivatives(h.state);
%     
%     %% Set output variable to a new state
%     for j = 1:numVar
%         x_dot(j,i+1) = h.state.getYDot().get(j-1);
%     end 
%     
%     S = addstruct(S,D);
%     
% end
% Y = cumsum(x_dot(:,1:end-1))';
% X = t';

plantHandle = @(t,x) OpenSimPlantFunction_fes(t, x, h, param);
integratorFunc = str2func(param.integrator.name); % Integrate the system equations
x_dot = zeros(numVar,1);
[X, Y] = integratorFunc(plantHandle, param.integrator.time, x_dot, param.integrator.options);

%% Create Output Data structure
S.name = [char(h.model.getName()), '_states'];
S.nRows = size(X, 1);
S.nColumns = size(X, 2) + size(Y, 2);
S.inDegrees = false;
S.labels = cell(1,S.nColumns);
S.labels{1}= 'time';

for j = 2:S.nColumns
    S.labels{j} = char(h.model.getStateVariableNames().getitem(j-2));
end

S.data = [X, Y];