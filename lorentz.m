% 3 parameter Lorentzian function

function f_out = lorentz(params, x)
    % params is a vector: <amp, gamma, x0>
    amp = params(1);
    gamma = params(2);
    x0 = params(3);
    
    f_out = amp./(1+((x-x0)/gamma).^2);
end