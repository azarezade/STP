%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------ Spatio-Temporal Model ----------------------------
% 
% Copyright by Ali Zarehzadeh and Sina Jafarzadeh 
% zarezade@ce.sharif.edu, jafarzadeh@ce.sharif.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% create the results folder if not exists
postfix='_synth';
folder_name=strcat(problem_unique_name,postfix);
mkdir([pwd,'/Results/Synth'],folder_name);

%% Load Data(the file is for synthetic data)
net = 'erdos';
file = fullfile(pwd,'Code', 'Data', 'Synth',[net '.mat']);
load(file);


temporal_loglikelihood_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_MSE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_MRE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_MAE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_loglikelihood_on_test_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_optimization_time_on_test_for_diffrent_data_sets=zeros(length(dataset_size),1);

spatial_loglikelihood_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_MSE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_MRE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_MAE_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);

spatial_MSE_exp_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_MRE_exp_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_MAE_exp_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);

spatial_loglikelihood_on_test_for_diffrent_data_sets=zeros(length(dataset_size),1);

   
%% unoverfit version
spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_MSE_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_MRE_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_MAE_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);

spatial_MSE_exp_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_MRE_exp_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_MAE_exp_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);

spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);




events_number=zeros(size(dataset_size)); %% number of events for each train set

   
for train_set=1:1:length(dataset_size)  
    

    train_percent = dataset_size(train_set);
    
    %% Print to the display
    fprintf('++++++++++++++++++++++++++++++++++++++++++ \n');
    fprintf('+   STP Method Started           + \n');
    fprintf('+   train_percent: %3.2f                  + \n', train_percent);
    fprintf('++++++++++++++++++++++++++++++++++++++++++ \n');

    num_event = floor(train_percent*length(events.times));
    num_test_events=floor(test_percentage*length(events.times));
    events_number(train_set)=num_event;
    

    data.adj=model.a;
    test.adj=model.a;

    data.times = events.times(max(1,end-(num_test_events+num_event)+1):end-(num_test_events)); %new version (from end slicing version)   
    test.times=events.times(end-num_test_events+1:end);
    
    
    data.nodes = events.nodes(max(1,end-(num_test_events+num_event)+1):end-(num_test_events)); %new version (from end slicing version)   
    test.nodes=events.nodes(end-num_test_events+1:end);
    
    data.categories = events.categories(max(1,end-(num_test_events+num_event)+1):end-(num_test_events)); %new version (from end slicing version)   
    test.categories=events.categories(end-num_test_events+1:end);
    
    data.locations = events.locations(max(1,end-(num_test_events+num_event)+1):end-(num_test_events)); %new version (from end slicing version)   
    test.locations=events.locations(end-num_test_events+1:end);
    
    
    data.times=data.times-data.times(1);%    
    %data.tmax =events.times(end-(num_test_events+1))-events.times(max(1,end-(num_test_events+num_event)));%new version   % maximum time of events (i.e. T)
    data.tmax=data.times(end);
    
    test.times=test.times-test.times(1);
    %test.tmax=events.times(end)-events.times(end-num_test_events);
    test.tmax=test.times(end);
    
    
    data.number_of_categories=model.categories;
    test.number_of_categories=model.categories;
    
    data.number_of_users=model.nodes;
    test.number_of_users=model.nodes;
    
    C =model.categories;
    

    
    log_likelihood_temporal_current_trainset=zeros(model.nodes,1);
    optimization_time_temporal_current_trainset=zeros(model.nodes,1);
    
    MSE_temporal_current_trainset=zeros(model.nodes,1);
    MRE_temporal_current_trainset=zeros(model.nodes,1);
    MAE_temporal_current_trainset=zeros(model.nodes,1);
    log_likelihood_temporal_on_test_current_trainset=zeros(model.nodes,1);
    
    
    

    
    log_likelihood_spatial_with_entropy=zeros(model.nodes,em_iterations+1);   
    MSE_spatial=zeros(model.nodes,em_iterations+1);
    MRE_spatial=zeros(model.nodes,em_iterations+1);
    MAE_spatial=zeros(model.nodes,em_iterations+1);
    
    MSE_exp_spatial=zeros(model.nodes,em_iterations+1);
    MRE_exp_spatial=zeros(model.nodes,em_iterations+1);
    MAE_exp_spatial=zeros(model.nodes,em_iterations+1);
    
    log_likelihood_on_test_spatial_with_entropy=zeros(model.nodes,em_iterations+1);

    d_adj = data.adj;
    




    %% code speed up techniques    
    data_for_each_user_in_each_category=cell(length(model.nodes),length(model.categories));
    test_for_each_user_in_each_category=cell(length(model.nodes),length(model.categories));
    
    data_for_each_user_and_his_neighs_in_each_categories=cell(length(model.nodes),length(model.categories));
    test_for_each_user_and_his_neighs_in_each_categories=cell(length(model.nodes),length(model.categories));
    
    data_for_each_user=cell(length(model.nodes));
    test_for_each_user=cell(length(model.nodes));
    
    data_for_each_user_and_neighs=cell(length(model.nodes));
    test_for_each_user_and_neighs=cell(length(model.nodes));
    
    
    data_in_each_categories=cell(model.categories,1);
    test_in_each_categories=cell(model.categories,1);
    
    
    for u=1:1:model.nodes

       ngbs_u=find(d_adj(:,u));
       
       data_for_each_user{u}.times=data.times(find(data.nodes==u));
       data_for_each_user{u}.nodes=data.nodes(find(data.nodes==u));
       data_for_each_user{u}.categories=data.categories(find(data.nodes==u));
       data_for_each_user{u}.locations=data.locations(find(data.nodes==u));
       
       test_for_each_user{u}.times=test.times(find(test.nodes==u));
       test_for_each_user{u}.nodes=test.nodes(find(test.nodes==u));
       test_for_each_user{u}.categories=test.categories(find(test.nodes==u));
       test_for_each_user{u}.locations=test.locations(find(test.nodes==u));
       
      
       
       data_for_each_user_and_neighs{u}.times=data.times(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{u}.nodes=data.nodes(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{u}.categories=data.categories(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{u}.locations=data.locations(find(ismember(data.nodes,ngbs_u)));
       
       test_for_each_user_and_neighs{u}.times=test.times(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{u}.nodes=test.nodes(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{u}.categories=test.categories(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{u}.locations=test.locations(find(ismember(test.nodes,ngbs_u)));
       
       
       for c=1:1:model.categories
            data_for_each_user_in_each_category{u}{c}.times=data.times(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{u}{c}.nodes=data.nodes(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{u}{c}.categories=data.categories(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{u}{c}.locations=data.locations(find(data.nodes==u & data.categories==c));
            
            test_for_each_user_in_each_category{u}{c}.times=test.times(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{u}{c}.nodes=test.nodes(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{u}{c}.categories=test.categories(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{u}{c}.locations=test.locations(find(test.nodes==u & test.categories==c));
            
       
            data_for_each_user_and_his_neighs_in_each_categories{u}{c}.times=data.times(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{u}{c}.nodes=data.nodes(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{u}{c}.categories=data.categories(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{u}{c}.locations=data.locations(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            
            
            test_for_each_user_and_his_neighs_in_each_categories{u}{c}.times=test.times(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{u}{c}.nodes=test.nodes(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{u}{c}.categories=test.categories(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{u}{c}.locations=test.locations(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            
            
       end        
    end
    
    for c=1:1:model.categories
       data_in_each_categories{c}.times=data.times(find(data.categories==c));
       data_in_each_categories{c}.nodes=data.nodes(find(data.categories==c)); 
       data_in_each_categories{c}.categories=data.categories(find(data.categories==c)); 
       data_in_each_categories{c}.locations=data.locations(find(data.categories==c)); 
       
       test_in_each_categories{c}.times=test.times(find(test.categories==c));
       test_in_each_categories{c}.nodes=test.nodes(find(test.categories==c)); 
       test_in_each_categories{c}.categories=test.categories(find(test.categories==c)); 
       test_in_each_categories{c}.locations=test.locations(find(test.categories==c));     
    end
    


    parfor u = 1:1:model.nodes

        disp(strcat('user',num2str(u)));
        fprintf('\n ************* User: %d ************\n',u);

        n_idx = find(model.a(:,u));
      
        ngbs_u=find(d_adj(:,u));
 
        %% problem temporal convex 
        if(problem_number==1)
          
            func_temporal=@(x)f_temporal(x,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);

            fgradian_temporal=@(x)fgrad_temporal(x,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name); 
            fhessian_temporal=@(x)fhess_temporal(x,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);
            fobjective_temporal=@(x)f_objective_no_hessian_temporal(func_temporal,fgradian_temporal,x);
        
            func_temporal_test=@(x)f_temporal(x,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);
            fgradian_temporal_test=@(x)fgrad_temporal(x,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);
            fhessian_temporal_test=@(x)fhess_temporal(x,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);

                    
            org_params_temporal=[model.mu(u,:)';model.beta_of_users(u)]; 

            initvar_temporal=[initvar_temporal_base_synth(1:model.categories);initvar_temporal_base_synth(model.categories+1)];           
            currentvar_temporal=initvar_temporal;
          
            start_time=cputime;
            if(strcmp(problem_unique_name,'temporal_social')==0)
                options=optimoptions(@fmincon,'Algorithm','interior-point','GradObj','on','MaxIter',15,'Display','iter','TolX',0.0001);            
                [currentvar_temporal,currentval_temporal]=fmincon(fobjective_temporal,currentvar_temporal,-1*eye(length(currentvar_temporal)),zeros(length(currentvar_temporal),1),[],[],[],[],[],options); 
            else
                options = optimset('MaxIter',15,'Display','Iter','TolX',0.0001);
                [currentvar_temporal,currentval_temporal]=fmincon(func_temporal,currentvar_temporal,-1*eye(length(currentvar_temporal)),zeros(length(currentvar_temporal),1),[],[],[],[],[],options); 
            end
            end_time=cputime;
           
          optimization_time_temporal_current_trainset(u,1)=end_time-start_time;
          
          log_likelihood_temporal_current_trainset(u,1)=func_temporal(currentvar_temporal);
          
          MSE_temporal_current_trainset(u,1)=sum(abs(currentvar_temporal-org_params_temporal).^2)/length(org_params_temporal);
          MRE_temporal_current_trainset(u,1)=sum(abs(currentvar_temporal-org_params_temporal)./abs(org_params_temporal))/length(org_params_temporal);
          MAE_temporal_current_trainset(u,1)=sum(abs(currentvar_temporal-org_params_temporal))/length(org_params_temporal);
          
          log_likelihood_temporal_on_test_current_trainset(u,1)=func_temporal_test(currentvar_temporal);
        end

        if(problem_number==2)

            org_params_spatial=[model.a(n_idx,u);model.eta(u,:)'];
            
            
            initvar_spatial=[initvar_spatial_base_synth(ngbs_u); initvar_spatial_base_synth(length(model.a)+1:length(initvar_spatial_base_synth))];
            initvar_spatial(1)=initvar_spatial(1)-(sum(initvar_spatial)-1);
            
            
            %if(randomness_of_org==1)
            %   vec=rand(size(org_params_spatial));
            %   vec=vec-(sum(vec)/length(vec));
            %   initvar_spatial=org_params_spatial+vec*50;
            %end
            
            
            currentvar_spatial=initvar_spatial;
            %currentvar_spatial=org_params_spatial;
           
            log_likelihood_spatial_with_entropy_temp=zeros(1,em_iterations+1);
            log_likelihood_on_test_spatial_with_entropy_temp=zeros(1,em_iterations+1);
          
            MSE_spatial_temp=zeros(1,em_iterations+1);
            MRE_spatial_temp=zeros(1,em_iterations+1);
            MAE_spatial_temp=zeros(1,em_iterations+1);
          
            MSE_exp_spatial_temp=zeros(1,em_iterations+1);
            MRE_exp_spatial_temp=zeros(1,em_iterations+1);
            MAE_exp_spatial_temp=zeros(1,em_iterations+1);
            
            currentvar_spatial_for_unoverfit=0; %%overfitting avoiding
            currentval_on_test_spatial_for_unoverfit=inf; %%overfitting avoiding

            estep_func=@(alpha,eta)estep(model,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},u,alpha,eta,problem_unique_name);
            estep_func_test=@(alpha,eta)estep(model,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},u,alpha,eta,problem_unique_name);
            
            func_spatial=@(x,z)f_spatial(x,z,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);        
            fgradian_spatial=@(x,z)fgrad_spatial(x,z,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);                
            fhessian_spatial=@(x,z)fhess_spatial(x,z,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);

            func_spatial_test=@(x,z)f_spatial(x,z,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},model, u,problem_unique_name);        
           
            for current_iter=1:1:em_iterations+1


            %% Expectation Computation
            Z=estep_func(currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end));
            %Z_org=estep_func(org_params_spatial(1:length(ngbs_u)),org_params_spatial(length(ngbs_u)+1:end));
            %Z=Z_org;

                if(current_iter==1)
                 
                  currentval_spatial=func_spatial(currentvar_spatial,Z);
                  entropy_value=entropy_calculator(model,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);     
                   
                  
                  log_likelihood_spatial_with_entropy_temp(current_iter)=currentval_spatial-entropy_value;
                  
                  MSE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial).^2)/length(org_params_spatial);
                  MRE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial)./abs(org_params_spatial))/length(org_params_spatial);
                  MAE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial))/length(org_params_spatial);

                  MSE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial)).^2)/length(org_params_spatial);
                  MRE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial))./abs(exp(org_params_spatial)))/length(org_params_spatial);
                  MAE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial)))/length(org_params_spatial);

                  
                  entropy_value_test=entropy_calculator(model,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name); 
                  Z_test=estep_func_test(currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end));
                  currentval_spatial_test=func_spatial_test(currentvar_spatial,Z_test);

                   
                  log_likelihood_on_test_spatial_with_entropy_temp(current_iter)=currentval_spatial_test-entropy_value_test;

                else
                    
                  disp(strcat(int2str(current_iter),'/',int2str(em_iterations)));
                  fobjective_spatial=@(x)f_objective_with_hessian_spatial(func_spatial,fgradian_spatial,fhessian_spatial,x,Z);
                  f_spat=@(x)func_spatial(x,Z);
                  options=optimoptions(@fminunc,'GradObj','on','Hessian','on','MaxIter',15,'Display','Iter');
                  [currentvar_spatial,~]=fminunc(fobjective_spatial,currentvar_spatial,options); 

%                   options=optimoptions(@fminunc,'MaxIter',15,'Display','Iter');
%                   [currentvar_spatial,~]=fminunc(f_spat,currentvar_spatial,options); 

                   sum_diffrence_normalization_factor=sum(currentvar_spatial);
                   sum_diffrence_normalization_factor=sum_diffrence_normalization_factor-1;
                   sum_diffrence_normalization_factor=sum_diffrence_normalization_factor/length(currentvar_spatial);
                   currentvar_spatial=currentvar_spatial-sum_diffrence_normalization_factor;

                   currentval_spatial=func_spatial(currentvar_spatial,Z);
                   currentval_spatial_test=func_spatial_test(currentvar_spatial,Z_test);

                   log_likelihood_spatial_with_entropy_temp(current_iter)=currentval_spatial-entropy_value; 
                   log_likelihood_on_test_spatial_with_entropy_temp(current_iter)=currentval_spatial_test-entropy_value_test;
                  
                   
                   %% overfitting avioding
                   if(log_likelihood_on_test_spatial_with_entropy_temp(current_iter)< currentval_on_test_spatial_for_unoverfit)
                      currentval_on_test_spatial_for_unoverfit=log_likelihood_on_test_spatial_with_entropy_temp(current_iter);
                      currentvar_spatial_for_unoverfit=currentvar_spatial;
                   end
                   
                  MSE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial).^2)/length(org_params_spatial);
                  MRE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial)./abs(org_params_spatial))/length(org_params_spatial);
                  MAE_spatial_temp(current_iter)=sum(abs(currentvar_spatial-org_params_spatial))/length(org_params_spatial);

                  MSE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial)).^2)/length(org_params_spatial);
                  MRE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial))./abs(exp(org_params_spatial)))/length(org_params_spatial);
                  MAE_exp_spatial_temp(current_iter)=sum(abs(exp(currentvar_spatial)-exp(org_params_spatial)))/length(org_params_spatial);

                  
                   entropy_value=entropy_calculator(model,data,data_in_each_categories,data_for_each_user{u},data_for_each_user_and_neighs{u},data_for_each_user_in_each_category{u},data_for_each_user_and_his_neighs_in_each_categories{u},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);
                   entropy_value_test=entropy_calculator(model,test,test_in_each_categories,test_for_each_user{u},test_for_each_user_and_neighs{u},test_for_each_user_in_each_category{u},test_for_each_user_and_his_neighs_in_each_categories{u},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);  

                end
            


            end

            log_likelihood_spatial_with_entropy(u,:)=log_likelihood_spatial_with_entropy_temp;
            log_likelihood_on_test_spatial_with_entropy(u,:)=log_likelihood_on_test_spatial_with_entropy_temp;
            
            MSE_spatial(u,:)=MSE_spatial_temp;
            MRE_spatial(u,:)=MRE_spatial_temp;
            MAE_spatial(u,:)=MAE_spatial_temp;    
         
            MSE_exp_spatial(u,:)=MSE_exp_spatial_temp;
            MRE_exp_spatial(u,:)=MRE_exp_spatial_temp;
            MAE_exp_spatial(u,:)=MAE_exp_spatial_temp;    
            
            
 
        end
        
        
        %% save learned parametes
        if(problem_number==2)
                title_temp=strcat('parameters_user_',num2str(u),'_trainset_',num2str(train_set),'.mat');        
                parsave(fullfile(pwd,'Results/Synth',folder_name,title_temp),{'currentvar_spatial',currentvar_spatial},{'currentvar_spatial_unoverfit',currentvar_spatial_for_unoverfit},{'initvar_spatial',initvar_spatial},{'org_params_spatial',org_params_spatial})
        elseif(problem_number==1)
                title_temp=strcat('parameters_user_',num2str(u),'_trainset_',num2str(train_set),'.mat');        
                parsave(fullfile(pwd,'Results/Synth',folder_name,title_temp),{'currentvar_temporal',currentvar_temporal},{'initvar_temporal',initvar_temporal},{'org_params_temporal',org_params_temporal});                
        end
        
     end
     
   temporal_loglikelihood_on_train_for_diffrent_data_sets(train_set)=sum(log_likelihood_temporal_current_trainset(:,end))/events_number(train_set);
   temporal_optimization_time_on_test_for_diffrent_data_sets(train_set)=sum(optimization_time_temporal_current_trainset(:,end)); 
   
   temporal_loglikelihood_on_test_for_diffrent_data_sets(train_set)=sum(log_likelihood_temporal_on_test_current_trainset(:,end))/num_test_events;

   temporal_MSE_on_train_for_diffrent_data_sets(train_set)=sum(MSE_temporal_current_trainset(:,end))/model.nodes;
  
   temporal_MRE_on_train_for_diffrent_data_sets(train_set)=sum(MRE_temporal_current_trainset(:,end))/model.nodes;
  
   temporal_MAE_on_train_for_diffrent_data_sets(train_set)=sum(MAE_temporal_current_trainset(:,end))/model.nodes;

   
   spatial_loglikelihood_on_train_for_diffrent_data_sets(train_set)=sum(log_likelihood_spatial_with_entropy(:,end))./events_number(train_set);
   spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(log_likelihood_spatial_with_entropy(:,2:end),[],2))./events_number(train_set);
   
   
   spatial_loglikelihood_on_test_for_diffrent_data_sets(train_set)=sum(log_likelihood_on_test_spatial_with_entropy(:,end))/num_test_events;
   spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit(train_set)=sum(min(log_likelihood_on_test_spatial_with_entropy(:,2:end),[],2))/num_test_events;
  
     
   spatial_MSE_on_train_for_diffrent_data_sets(train_set)=sum(MSE_spatial(:,end))/model.nodes;
   spatial_MSE_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MSE_spatial(:,2:end),[],2))/model.nodes;
   
      
   spatial_MRE_on_train_for_diffrent_data_sets(train_set)=sum(MRE_spatial(:,end))/model.nodes;
   spatial_MRE_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MRE_spatial(:,2:end),[],2))/model.nodes;
   
   spatial_MAE_on_train_for_diffrent_data_sets(train_set)=sum(MAE_spatial(:,end))/model.nodes;
   spatial_MAE_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MAE_spatial(:,2:end),[],2))/model.nodes;
   
   
   spatial_MSE_exp_on_train_for_diffrent_data_sets(train_set)=sum(MSE_exp_spatial(:,end))/model.nodes;
   spatial_MSE_exp_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MSE_exp_spatial(:,2:end),[],2))/model.nodes;
   
      
   spatial_MRE_exp_on_train_for_diffrent_data_sets(train_set)=sum(MRE_exp_spatial(:,end))/model.nodes;
   spatial_MRE_exp_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MRE_exp_spatial(:,2:end),[],2))/model.nodes;
   
   spatial_MAE_exp_on_train_for_diffrent_data_sets(train_set)=sum(MAE_exp_spatial(:,end))/model.nodes;
   spatial_MAE_exp_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(MAE_exp_spatial(:,2:end),[],2))/model.nodes;
   
   
end

%% final results part temporal
if(problem_number==1)
    
     plot(dataset_size,temporal_loglikelihood_on_test_for_diffrent_data_sets);
     title('temporal_loglikelihood_on_test_for_diffrent_data_sets');    
     file_name=fullfile(pwd,'Results/Synth',folder_name,'temporal_loglikelihood_on_test_for_diffrent_data_sets');                             
     print(file_name,'-dpng');
     close 

     title_temp=strcat('temporal_evaluations','.mat');      
     save(fullfile(pwd,'Results/Synth',folder_name,title_temp),'temporal_loglikelihood_on_test_for_diffrent_data_sets','temporal_loglikelihood_on_train_for_diffrent_data_sets','temporal_MAE_on_train_for_diffrent_data_sets','temporal_MRE_on_train_for_diffrent_data_sets','temporal_MSE_on_train_for_diffrent_data_sets','temporal_optimization_time_on_test_for_diffrent_data_sets');

end

%% final result part spatial
if(problem_number==2)
    
     plot(dataset_size,spatial_loglikelihood_on_test_for_diffrent_data_sets);
     title('spatial_loglikelihood_on_test_for_diffrent_data_sets');    
     file_name=fullfile(pwd,'Results/Synth',folder_name,'spatial_loglikelihood_on_test_for_diffrent_data_sets');             
     print(file_name,'-dpng');
     close 
     
     
     plot(dataset_size,spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit);
     title('spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit');    
     file_name=fullfile(pwd,'Results/Synth',folder_name,'spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit');             
     print(file_name,'-dpng');
     close 
     
     title_temp=strcat('spatial_evaluations','.mat');      
     save(fullfile(pwd,'Results/Synth',folder_name,title_temp),'spatial_loglikelihood_on_test_for_diffrent_data_sets','spatial_loglikelihood_on_train_for_diffrent_data_sets','spatial_MAE_on_train_for_diffrent_data_sets','spatial_MRE_on_train_for_diffrent_data_sets','spatial_MSE_on_train_for_diffrent_data_sets','spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit','spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit','spatial_MAE_on_train_for_diffrent_data_sets_unoverfit','spatial_MRE_on_train_for_diffrent_data_sets_unoverfit','spatial_MSE_on_train_for_diffrent_data_sets_unoverfit','spatial_MSE_exp_on_train_for_diffrent_data_sets','spatial_MSE_exp_on_train_for_diffrent_data_sets_unoverfit','spatial_MRE_exp_on_train_for_diffrent_data_sets','spatial_MRE_exp_on_train_for_diffrent_data_sets_unoverfit','spatial_MAE_exp_on_train_for_diffrent_data_sets','spatial_MAE_exp_on_train_for_diffrent_data_sets_unoverfit');
     
end
    

