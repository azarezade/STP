%% priodic gaussian kernel
function value = g_exp(t,ti,integral,model)
% inputs:
%     integral:if integral set to one the value is the integral of PGK from ti to t.
w=model.w;
sigma=model.sigma_exponential;


if(integral==0)            

    value=exp(-1*sigma*(t-ti));
else

value=-1*(1/sigma)*(exp(-1*sigma*(t-ti))-1);
end

 
end

