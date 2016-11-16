function  [value] = f_spatial(vari,Z,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model, u,method)
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
%C = model.categories; % number of categories

U = model.nodes; %number of users

ngbs_u = find(data.adj(:,u));


a_u = vari(1:length(ngbs_u))';
eta_u=vari(length(ngbs_u)+1:end)';

log_sum_lambda=0;

for i = 1:length(data_u.times)
    v=0;
    gamma_func_value=gamma_func(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,v,data_u.categories(i),data_u.locations(i),data_u.times(i),exp(eta_u),exp(a_u),ngbs_u,method);
    log_sum_lambda=log_sum_lambda-Z(i,v+1)*log(gamma_func_value);
    for j=1:1:length(ngbs_u) 
        v=ngbs_u(j);
        gamma_func_value=gamma_func(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,v,data_u.categories(i),data_u.locations(i),data_u.times(i),exp(eta_u),exp(a_u),ngbs_u,method);
        if(gamma_func_value~=0)
        log_sum_lambda=log_sum_lambda-Z(i,v+1)*log(gamma_func_value); 
        end
    end
end

value=log_sum_lambda;
end