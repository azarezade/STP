%% checked
function  [value] = f_temporal(vari,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,u,method)


% Function to be optimized in barrier method for STP method:
% The partial log-Likelihood of the events of a user u which is given to the
% function in data + the penalty of barrier method for constraints.
% Inputs:
%   data: a struct containing the followings:
%       data.times: the vector of times of events 
%       data.nodes: the vector of nodes of events 
%       data.categories: the vector of products of events
%       data.locations: the vector of locations of places
%       data.tmax: maximum time for which we want to calculate the likelihood 
%           of occuring events in (0, tmax)
%   u: the user for whom we do the calculations
%   var: a vector containing the mu(vector),beta_of_users(scalar),alpha(vector),eta(vector) vectors for the selected user
%       in a sequence after each other
%   barrier_t: the t parameter of barrier method
% Outputs:
%   value: The final value containing the loglikelihood + penalty of
%       barrier method for constraints
%   value_without_barrier: The partial log-likelihoof value
C = model.categories; % number of categories

mu_u = vari(1:C)';




tmax=data.tmax;



log_sum_lambda=0;

%% the first part of I
new_model=model;
new_model.mu(u,:)=mu_u;
if(strcmp(method,'temporal_social')==1)
a_temporal=vari(C+1);
new_model.a_temporal(u)=a_temporal;   
else
    beta_of_users=vari(C+1);
    new_model.beta_of_users(u)=beta_of_users;
end

for c=1:1:model.categories
landa_integral=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats, tmax,1,u,c,method);
%log_sum_lambda=log_sum_lambda+landa_integral(u,c);
log_sum_lambda=log_sum_lambda+landa_integral; 
end

%landa_integral=integral_calculator(new_model, data, tmax,u);
for i = 1:length(data_u.times)
    
    tn = data_u.times(i);
    cn=data_u.categories(i);

    %% the second part of I
    landa=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,tn,0,u,cn,method);
    landa_un_cn=landa;   
    log_sum_lambda = log_sum_lambda-log(landa_un_cn);
end

value = log_sum_lambda;

end