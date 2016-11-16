%% checked
function value = fgrad_temporal(vari,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model, u,method)

% This function calculated the Gradeint and Hessian of function f using current value of
%   parameters in var for STP method.
% Inputs:
%   data: a struct containing the followings:
%       data.times: the vector of times of data 
%       data.nodes: the vector of nodes of data 
%       data.categories: the vector of products of data
%       data.locations: the vector of locations of places
%       data.tmax: maximum time for which we want to calculate the likelihood 
%           of occuring data in (0, tmax)
%   u: the user for whom we do the calculations
%   var: a vector containing the mu(vector),beta_of_users(scalar),alpha(vector),eta(vector) vectors for the selected user
%       in a sequence after each other
%   barrier_t: the t parameter of barrier method
% Outputs:
%   grad: the gradient vector and hessian matrix of the function f for user u

C = model.categories; % number of categories


mu_u = vari(1:C)';
beta_of_users=vari(C+1);

%locs=data.locations;


%% gradient in the direction of mu_u vector
mu_u_diff = zeros(1,C);
%% gradient in the direction of beta_of_users of user u
beta_u_diff=0;

for c=1:1:C
    for i = 1:length(data_u_cats{c}.times)
        tmax = data.tmax;

        tn=data_u_cats{c}.times(i);
        %c=data_u.categories(i);

        new_model=model;
        new_model.beta_of_users(u)=beta_of_users;
        new_model.mu(u,:)=mu_u;
        I_u=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,tn,0,u,c,method);

        mu_u_diff(c) = mu_u_diff(c) - 1/I_u;

        new_model.mu(u,:)= new_model.mu(u,:)*0;
        new_model.beta_of_users(u)=1;
        A=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,tn,0,u,c,method);

        beta_u_diff=beta_u_diff-(A/I_u);

           if(i+100<=length(data_u_cats{c}.times))
               tn_prime=data_u_cats{c}.times(i+100);
               tmax=tn_prime;
           end
    %   
        if(strcmp(method,'temporal_simple')==1)
            beta_u_diff=beta_u_diff+g(tmax,tn,1,new_model);        
        else
            beta_u_diff=beta_u_diff+g_exp(tmax,tn,1,new_model);
        end
        %end
    end
end
mu_u_diff=mu_u_diff+data.tmax;


value=[mu_u_diff';beta_u_diff'];


end