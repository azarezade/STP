%% blah blah
function value = fhess_temporal(vari,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model, u,method)

C = model.categories; % number of categories

mu_u = vari(1:C)';
beta_of_users=vari(C+1);


%% hessian of mu and beta_of_users
mu_mu_diff=zeros(C,C);
mu_beta_diff=zeros(C,1);
beta_beta_diff=zeros(1,1);


for i = 1:length(data_u.times)
    %n = inds(i);
    tn = data_u.times(i);
    cn = data_u.categories(i);
    
    
    new_model=model;
    new_model.mu(u,:)=mu_u;
    new_model.beta_of_users(u)=beta_of_users;
    I_u=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats, tn,0,u,method);
    
    
    new_model.mu(u,:)=mu_u*0;
    new_model.beta_of_users(u)=1;
    A=stp_intensity(new_model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats, tn,0,u,method);


    mu_mu_diff(cn,cn)=mu_mu_diff(cn,cn)+ 1/(I_u(u,cn)^2);
    beta_beta_diff=beta_beta_diff+(A(u,cn)/I_u(u,cn))^2;
    
    mu_beta_diff(cn)=mu_beta_diff(cn)+(A(u,cn)/(I_u(u,cn)^2));

   
end



value=[mu_mu_diff,mu_beta_diff;mu_beta_diff',beta_beta_diff];

end