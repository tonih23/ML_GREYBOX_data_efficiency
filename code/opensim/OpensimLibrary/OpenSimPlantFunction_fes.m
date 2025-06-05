                 
% ----------------------------------------------------------------------- 
%OpenSimPlantFunction  
%   x_dot = OpenSimPlantFunction(t, x, controlsFuncHandle, osimModel, 
%   osimState) converts an OpenSimModel and an OpenSimState into a 
%   function which can be passed as a input to a Matlab integrator, such as
%   ode45, or an optimization routine, such as fmin.
%
% Input:
%   t is the time at the current step
%   x is a Matlab column matrix of state values at the current step
%   controlsFuncHandle is a handle to a function which computes thecontrol
%   vector
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   x_dot is a Matlab column matrix of the derivative of the state values
% ----------------------------------------------------------------------- 
function [x_dot, controlValues,param] = OpenSimPlantFunction_fes(t, x, h, param)
    % Update state with current values  
    h.state.setTime(t);
    numVar = h.state.getNY();
    for i = 0:1:numVar-1
        h.state.updY().set(i, x(i+1,1));
    end
    
    % Update the state velocity calculations
    h.model.computeStateVariableDerivatives(h.state);
    
    % Update model with control values
    if(~isempty(h.control))
       [controlVector,param] = h.control(h, param);
       h.model.setControls(h.state, controlVector);
       for i = 1:h.model.getNumControls()
           controlValues(1) = controlVector.get(i-1);
       end
    end

    % Update the derivative calculations in the State Variable
    h.model.computeStateVariableDerivatives(h.state);
    
    x_dot = zeros(numVar,1);
    % Set output variable to new state
    for i = 0:1:numVar-1
        x_dot(i+1,1) = h.state.getYDot().get(i);
    end
end