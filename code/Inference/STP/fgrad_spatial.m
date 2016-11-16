function value = fgrad_spatial(vari,Z,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model, u,method)
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


ngbs_u = find(data.adj(:,u));

a_u=vari(1:length(ngbs_u))';


eta_u=vari(length(ngbs_u)+1:end)';


%% gradient in the direction of alpha of user u
alpha_u_diff = zeros(1, length(ngbs_u));
%% gradient in the direction of eta of user u
eta_u_diff=zeros(1,C);



for i = 1:length(data_u.times)
    tn = data_u.times(i);
    cn = data_u.categories(i);
    locn=data_u.locations(i);

    [~,~,~,modified_denuminator,~]=gamma_func(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,0,cn,locn,tn,exp(eta_u),exp(a_u),ngbs_u,method); %% ngbs_u(1) imported because there is no diffrence in the argument in this part (the denuminator is independent of this arguments)    
    denumenator=modified_denuminator;
    
    for ng=1:1:length(ngbs_u) % iterate over w
                
       %% derivative of each neighbor update for current data    
       interval_end=find(data_u_neighs_cats{cn}.times>=tn,1);
       if(isempty(interval_end))
           interval_end=length(data_u_neighs_cats{cn}.times);
       else
           interval_end=interval_end-1;
       end
       interval_start=max(1,interval_end-100);
       
       data_of_this_neighber_indices=find(data_u_neighs_cats{cn}.nodes(interval_start:interval_end)==ngbs_u(ng));
       data_of_this_neighber_indices=data_of_this_neighber_indices+(interval_start-1);
       
       if(strcmp(method,'spatial_etk_period_consideration')==1)
           exp_of_times=exp(-model.sigma_location_exponential*(abs((tn-model.w)-data_u_neighs_cats{cn}.times(data_of_this_neighber_indices)))); 
       else
           exp_of_times=exp(-model.sigma_location_exponential*(tn-data_u_neighs_cats{cn}.times(data_of_this_neighber_indices)));    
       end
       
       
       if(strcmp(method,'spatial_tik')==1)
           temp1_in_II_context=(exp(a_u(ng))*length(exp_of_times));% changed in STIL
       else
           temp1_in_II_context=(exp(a_u(ng))*sum(exp_of_times));% changed in STIL
       end

       alpha_u_diff(ng)=alpha_u_diff(ng)-sum(Z(i,:))*(-(temp1_in_II_context/denumenator));
       alpha_u_diff(ng)=alpha_u_diff(ng)-Z(i,ngbs_u(ng)+1);

    end

    eta_u_diff(cn)=eta_u_diff(cn)-sum(Z(i,1:end))*(-1*(exp(eta_u(cn)))/denumenator);
    eta_u_diff(cn)=eta_u_diff(cn)-Z(i,1);
end

value=[alpha_u_diff';eta_u_diff'];
end