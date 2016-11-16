function value = fhess_spatial(vari,Z,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model, u,method)

C = model.categories; % number of categories


ngbs_u = find(data.adj(:,u));


a_u=vari(1:length(ngbs_u))';

eta_u=vari(length(ngbs_u)+1:end)';


%% hessian of alpha and eta
alpha_alpha_diff=zeros(length(ngbs_u),length(ngbs_u));
alpha_eta_diff=zeros(length(ngbs_u),C);
eta_eta_diff=zeros(C,C);

for i = 1:length(data_u.times)
    %n = inds(i);
    tn = data_u.times(i);
    cn = data_u.categories(i);
    locn=data_u.locations(i);
 
    %start_inds=ins(max(1,i-30));
    %current_inds=n;
    
    
    [~,~,~,modified_denuminator,W_uc]=gamma_func(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,0,cn,locn,tn,exp(eta_u),exp(a_u),ngbs_u,method); %% ngbs_u(1) imported because there is no diffrence in the argument in this part (the denuminator is independent of this arguments)    

    denumenator=modified_denuminator;
    
    for ng=1:1:length(ngbs_u)
       %data_of_this_neighber_indices=find(times<tn & nodes==ngbs_u(ng) &  categories==cn);
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
       
       %temp1_in_II_context=(exp(a_u(ngbs_u(ng)))*sum(exp_of_times));
       if(strcmp(method,'spatial_tik')==1)
           temp1_in_II_context=(exp(a_u(ng))*length(exp_of_times));% changed in STIL
       else
           temp1_in_II_context=(exp(a_u(ng))*sum(exp_of_times));% changed in STIL
       end
       

       
       alpha_alpha_diff(ng,ng)=alpha_alpha_diff(ng,ng)-sum(Z(i,:))*(-(temp1_in_II_context/denumenator) +(temp1_in_II_context/denumenator)^2 );


       alpha_eta_diff(ng,cn)=alpha_eta_diff(ng,cn)-sum(Z(i,:))*exp(eta_u(cn))*(temp1_in_II_context/denumenator^2);
        
       for ng2=1:1:length(ngbs_u)
           %data_of_this_neighber_indices=find(times<tn & times>tn-168 & nodes==ngbs_u(ng2) &  categories==cn);
           
           %inds_ct=find(data.categories==cn & data.times<tn);
           
           interval_end=find(data_u_neighs_cats{cn}.times>tn);
           if(isempty(interval_end))
               interval_end=length(data_u_neighs_cats{cn}.times);
           else
               interval_end=interval_end-1;
           end
           
           data_of_second_neighber_indices=find(data_u_neighs_cats{cn}.nodes(1:interval_end)==ngbs_u(ng2));
           
           if(strcmp(method,'spatial_etk_period_consideration')==1)
                 exp_of_times=exp(-model.sigma_location_exponential*(abs((tn-model.w)-data_u_neighs_cats{cn}.times(data_of_second_neighber_indices))));

           else
                 exp_of_times=exp(-model.sigma_location_exponential*(tn-data_u_neighs_cats{cn}.times(data_of_second_neighber_indices)));
 
           end
           
           if(strcmp(method,'spatial_tik')==1)
           temp2_in_II_context=(exp(a_u(ng2))*length(exp_of_times)); %% changed in STIL
           else
           temp2_in_II_context=(exp(a_u(ng2))*sum(exp_of_times)); %% changed in STIL
           end
           
           if(ng2~=ng)
           alpha_alpha_diff(ng,ng2)=alpha_alpha_diff(ng,ng2)-sum(Z(i,:))*(temp1_in_II_context*temp2_in_II_context/(denumenator^2));
         
           end
       end

    end

%    if(~isempty(ngbs_u))
    eta_eta_diff(cn,cn)=eta_eta_diff(cn,cn)-sum(Z(i,2:end))*(-exp(eta_u(cn))/denumenator + (exp(2*eta_u(cn))/denumenator^2) );
%    end
    eta_eta_diff(cn,cn)=eta_eta_diff(cn,cn)-sum(Z(i,1))*(-(exp(eta_u(cn))*W_uc)/(denumenator^2) );
    
 end


value=[alpha_alpha_diff,alpha_eta_diff;alpha_eta_diff',eta_eta_diff];

end