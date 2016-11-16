%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------ Spatio-Temporal Model ----------------------------
% 
% Copyright by Ali Zarehzadeh and Sina Jafarzadeh 
% zarezade@ce.sharif.edu, jafarzadeh@ce.sharif.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blah blah blah

%% create the results folder if not exists

postfix='_real';
folder_name=strcat(problem_unique_name,postfix);

mkdir([pwd,'/Results/Real'],folder_name);

%% Load Data(the file is for synthetic data)
net = '4sq';
file = fullfile(pwd,'Code', 'Data', 'Real',[net '.mat']);
load(file);


temporal_loglikelihood_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
temporal_optimization_time_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);

temporal_loglikelihood_on_test_for_diffrent_data_sets=zeros(length(dataset_size),1);

spatial_loglikelihood_on_train_for_diffrent_data_sets=zeros(length(dataset_size),1);
spatial_loglikelihood_on_test_for_diffrent_data_sets=zeros(length(dataset_size),1);

%% unoverfit version
spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);
spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit=zeros(length(dataset_size),1);


events_number=zeros(size(dataset_size)); %% number of events for each train set

number_of_users=nodes_for_experiment;



failed_users=zeros(nodes_for_experiment,1);
for train_set=1:1:length(dataset_size)  

    failed_users_current=zeros(nodes_for_experiment,1);
    train_days=dataset_size_in_days(train_set);
        
    %% Print to the display
    fprintf('++++++++++++++++++++++++++++++++++++++++++ \n');
    fprintf('+   STP Method Started           + \n');
    fprintf('+   train_days: %3.2f                  + \n', train_days);
    fprintf('++++++++++++++++++++++++++++++++++++++++++ \n');

    
    num_test_events=find(events.times>events.times(end)-day2hour(test_size_in_days),1);
    num_test_events=length(events.times)-num_test_events;
    

    num_event=find(events.times>events.times(end)-(day2hour(test_size_in_days)+day2hour(dataset_size_in_days(train_set))),1);
    num_event=length(events.times)-(num_test_events+num_event);
    
    
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
    
    
    
    data.times=data.times-data.times(1);  
    %data.tmax =events.times(end-(num_test_events+1))-events.times(max(1,end-(num_test_events+num_events)));%new version   % maximum time of events (i.e. T)
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
    log_likelihood_temporal_on_test_current_trainset=zeros(model.nodes,1);


    
    log_likelihood_spatial_with_entropy=zeros(model.nodes,em_iterations+1);          
    log_likelihood_on_test_spatial_with_entropy=zeros(model.nodes,em_iterations+1);


    d_adj = data.adj;
    
    

    %% code speed up techniques
    data_for_each_user_in_each_category=cell(length(nodes_for_experiment),length(model.categories));
    test_for_each_user_in_each_category=cell(length(nodes_for_experiment),length(model.categories));
    
    data_for_each_user_and_his_neighs_in_each_categories=cell(length(nodes_for_experiment),length(model.categories));
    test_for_each_user_and_his_neighs_in_each_categories=cell(length(nodes_for_experiment),length(model.categories));
    
    data_for_each_user=cell(length(nodes_for_experiment));
    test_for_each_user=cell(length(nodes_for_experiment));
    
    data_for_each_user_and_neighs=cell(length(nodes_for_experiment));
    test_for_each_user_and_neighs=cell(length(nodes_for_experiment));
    
    
    data_in_each_categories=cell(model.categories,1);
    test_in_each_categories=cell(model.categories,1);
    
    
    for i=1:1:nodes_for_experiment 
       u=users_top(i);
       ngbs_u=find(d_adj(:,u));
       
       data_for_each_user{i}.times=data.times(find(data.nodes==u));
       data_for_each_user{i}.nodes=data.nodes(find(data.nodes==u));
       data_for_each_user{i}.categories=data.categories(find(data.nodes==u));
       data_for_each_user{i}.locations=data.locations(find(data.nodes==u));
       
       test_for_each_user{i}.times=test.times(find(test.nodes==u));
       test_for_each_user{i}.nodes=test.nodes(find(test.nodes==u));
       test_for_each_user{i}.categories=test.categories(find(test.nodes==u));
       test_for_each_user{i}.locations=test.locations(find(test.nodes==u));
       
      
       
       data_for_each_user_and_neighs{i}.times=data.times(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{i}.nodes=data.nodes(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{i}.categories=data.categories(find(ismember(data.nodes,ngbs_u)));
       data_for_each_user_and_neighs{i}.locations=data.locations(find(ismember(data.nodes,ngbs_u)));
       
       test_for_each_user_and_neighs{i}.times=test.times(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{i}.nodes=test.nodes(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{i}.categories=test.categories(find(ismember(test.nodes,ngbs_u)));
       test_for_each_user_and_neighs{i}.locations=test.locations(find(ismember(test.nodes,ngbs_u)));
       
       
       for c=1:1:model.categories
            data_for_each_user_in_each_category{i}{c}.times=data.times(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{i}{c}.nodes=data.nodes(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{i}{c}.categories=data.categories(find(data.nodes==u & data.categories==c));
            data_for_each_user_in_each_category{i}{c}.locations=data.locations(find(data.nodes==u & data.categories==c));
            
            test_for_each_user_in_each_category{i}{c}.times=test.times(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{i}{c}.nodes=test.nodes(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{i}{c}.categories=test.categories(find(test.nodes==u & test.categories==c));
            test_for_each_user_in_each_category{i}{c}.locations=test.locations(find(test.nodes==u & test.categories==c));
            
       
            data_for_each_user_and_his_neighs_in_each_categories{i}{c}.times=data.times(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{i}{c}.nodes=data.nodes(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{i}{c}.categories=data.categories(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            data_for_each_user_and_his_neighs_in_each_categories{i}{c}.locations=data.locations(find(ismember(data.nodes,ngbs_u) & data.categories==c));
            
            
            test_for_each_user_and_his_neighs_in_each_categories{i}{c}.times=test.times(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{i}{c}.nodes=test.nodes(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{i}{c}.categories=test.categories(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            test_for_each_user_and_his_neighs_in_each_categories{i}{c}.locations=test.locations(find(ismember(test.nodes,ngbs_u) & test.categories==c));
            
            
       end        
    end
    
    for u=1:1:model.categories
       data_in_each_categories{u}.times=data.times(find(data.categories==u));
       data_in_each_categories{u}.nodes=data.nodes(find(data.categories==u)); 
       data_in_each_categories{u}.categories=data.categories(find(data.categories==u)); 
       data_in_each_categories{u}.locations=data.locations(find(data.categories==u)); 
       
       test_in_each_categories{u}.times=test.times(find(test.categories==u));
       test_in_each_categories{u}.nodes=test.nodes(find(test.categories==u)); 
       test_in_each_categories{u}.categories=test.categories(find(test.categories==u)); 
       test_in_each_categories{u}.locations=test.locations(find(test.categories==u));     
    end
    

    disp('optimization started');
    parfor i = 1:1:nodes_for_experiment
        u=users_top(i);      
        disp(u);
        fprintf('\n ************* User: %d ************\n',u);
            
        n_idx = find(model.a(:,u));
        
        ngbs_u=find(d_adj(:,u));
        


       
        %% problem temporal convex 
        if(problem_number==1 || problem_number==3)
            
              if(strcmp(problem_unique_name,'temporal_social')==1)
                    initvar_temporal=[initvar_temporal_base_real(1:model.categories);initvar_temporal_base_real(model.categories+ngbs_u)];    
              else
                    initvar_temporal=[initvar_temporal_base_real(1:model.categories);initvar_temporal_base_real(model.categories+1)];            
              end
         
              currentvar_temporal=initvar_temporal;
        

        
            func_temporal=@(x)f_temporal(x, data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);

            fgradian_temporal=@(x)fgrad_temporal(x,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name); 

            fhessian_temporal=@(x,lambda)fhess_temporal(x,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i}, model, u,problem_unique_name);
            fobjective_temporal=@(x)f_objective_no_hessian_temporal(func_temporal,fgradian_temporal,x);

            func_temporal_test=@(x)f_temporal(x,test,test_in_each_categories,test_for_each_user{i},test_for_each_user_and_neighs{i},test_for_each_user_in_each_category{i},test_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);


        
          %options=optimoptions(@fmincon,'Algorithm','interior-point','GradObj','on','Hessian','user-supplied','HessFcn',fhessian_temporal,'MaxIter',15,'Display','iter');            
          
          start_time=cputime;
          if(strcmp(problem_unique_name,'temporal_social')==0)
          options=optimoptions(@fmincon,'Algorithm','interior-point','GradObj','on','MaxIter',15,'Display','iter','TolX',0.0001);            
          [currentvar_temporal,currentval_temporal]=fmincon(fobjective_temporal,currentvar_temporal,-1*eye(length(currentvar_temporal)),zeros(length(currentvar_temporal),1),[],[],[],[],[],options); 
          else
           options = optimset('MaxIter',15,'Display','Iter');
          [currentvar_temporal,currentval_temporal]=fmincon(func_temporal,currentvar_temporal,-1*eye(length(currentvar_temporal)),zeros(length(currentvar_temporal),1),[],[],[],[],[],options); 
          
          end
          end_time=cputime;
          
          optimization_time_temporal_current_trainset(i,1)=end_time-start_time;
          
          currentvar_temporal(currentvar_temporal<0)=0.00000001;
          
          log_likelihood_temporal_current_trainset(i,1)=func_temporal(currentvar_temporal);
          log_likelihood_temporal_on_test_current_trainset(i,1)=func_temporal_test(currentvar_temporal);                     
        end

        if(problem_number==2 || problem_number==3)
            
            infinite_flag=0% some users optimization fail for some initial points. we don't consider those users.
            
            initvar_spatial=[initvar_spatial_base_real(ngbs_u); initvar_spatial_base_real(length(model.a)+1:length(initvar_spatial_base_real))];
            initvar_spatial(1)=initvar_spatial(1)-(sum(initvar_spatial)-1);
            %initvar_spatial(2:end)=initvar_spatial(2:end)-15;
            %initvar_spatial(1)=(length(initvar_spatial)-1)*15+ initvar_spatial(1);
            currentvar_spatial=initvar_spatial;
         
           
            log_likelihood_spatial_with_entropy_temp=zeros(1,em_iterations+1);
            log_likelihood_on_test_spatial_with_entropy_temp=zeros(1,em_iterations+1);
          

            currentvar_spatial_for_unoverfit=0; %%overfitting avoiding
            currentval_on_test_spatial_for_unoverfit=inf; %%overfitting avoiding

            estep_func=@(alpha,eta)estep(model,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},u,alpha,eta,problem_unique_name);
            estep_func_test=@(alpha,eta)estep(model,test,test_in_each_categories,test_for_each_user{i},test_for_each_user_and_neighs{i},test_for_each_user_in_each_category{i},test_for_each_user_and_his_neighs_in_each_categories{i},u,alpha,eta,problem_unique_name);
            
            func_spatial=@(x,z)f_spatial(x,z,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);        
            fgradian_spatial=@(x,z)fgrad_spatial(x,z,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);                
            fhessian_spatial=@(x,z)fhess_spatial(x,z,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);

            func_spatial_test=@(x,z)f_spatial(x,z,test,test_in_each_categories,test_for_each_user{i},test_for_each_user_and_neighs{i},test_for_each_user_in_each_category{i},test_for_each_user_and_his_neighs_in_each_categories{i},model, u,problem_unique_name);        
                       
            for current_iter=1:1:em_iterations+1
            
            
            
            %% Expectation Computation
            Z=estep_func(currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end));
            Z_test=estep_func_test(currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end));


                if(current_iter==1)
                 
                  currentval_spatial=func_spatial(currentvar_spatial,Z);
                  entropy_value=entropy_calculator(model,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);     
                   
                  
                  log_likelihood_spatial_with_entropy_temp(current_iter)=currentval_spatial-entropy_value;

                  entropy_value_test=entropy_calculator(model,test,test_in_each_categories,test_for_each_user{i},test_for_each_user_and_neighs{i},test_for_each_user_in_each_category{i},test_for_each_user_and_his_neighs_in_each_categories{i},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name); 
                  Z_test=estep_func_test(currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end));
                  currentval_spatial_test=func_spatial_test(currentvar_spatial,Z_test);

                   
                  log_likelihood_on_test_spatial_with_entropy_temp(current_iter)=currentval_spatial_test-entropy_value_test;

                else
                   disp(strcat(int2str(current_iter-1),'/',int2str(em_iterations)));
                   fobjective_spatial=@(x)f_objective_with_hessian_spatial(func_spatial,fgradian_spatial,fhessian_spatial,x,Z);
                   %fobjective_spatial=@(x)func_spatial(x,Z);
                   options=optimoptions(@fminunc,'GradObj','on','Hessian','on','MaxIter',15,'Display','Iter');
                   %currentvar_spatial_before_optimization=currentvar_spatial;
                   try
                        [currentvar_spatial,~]=fminunc(fobjective_spatial,currentvar_spatial,options); 
                   catch
                        infinite_flag=1;
                        failed_users(i)=1;
                        failed_users_current(i)=1;
                        break;
                        %currentvar_spatial=currentvar_spatial_before_optimization;
                        
                   end
                  %options=optimoptions(@fminunc,'MaxIter',15,'Display','Iter');
                  %[currentvar_spatial,~]=fminunc(fobjective_spatial,currentvar_spatial,options); 
                   
                    
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

                   entropy_value=entropy_calculator(model,data,data_in_each_categories,data_for_each_user{i},data_for_each_user_and_neighs{i},data_for_each_user_in_each_category{i},data_for_each_user_and_his_neighs_in_each_categories{i},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);
                   entropy_value_test=entropy_calculator(model,test,test_in_each_categories,test_for_each_user{i},test_for_each_user_and_neighs{i},test_for_each_user_in_each_category{i},test_for_each_user_and_his_neighs_in_each_categories{i},u,currentvar_spatial(1:length(ngbs_u)),currentvar_spatial(length(ngbs_u)+1:end),problem_unique_name);  


                end
            


            end

            if(infinite_flag==0)
            log_likelihood_spatial_with_entropy(i,:)=log_likelihood_spatial_with_entropy_temp;
            log_likelihood_on_test_spatial_with_entropy(i,:)=log_likelihood_on_test_spatial_with_entropy_temp;
            end    

        end
       
        %% save learned parametes
        if(problem_number==2)
                title_temp=strcat('parameters_user_',num2str(u),'_trainset_',num2str(train_set),'.mat');        
                parsave(fullfile(pwd,'Results/Real',folder_name,title_temp),{'currentvar_spatial',currentvar_spatial},{'currentvar_spatial_unoverfit',currentvar_spatial_for_unoverfit},{'initvar_spatial',initvar_spatial})
        elseif(problem_number==1)
                title_temp=strcat('parameters_user_',num2str(u),'_trainset_',num2str(train_set),'.mat');        
                parsave(fullfile(pwd,'Results/Real',folder_name,title_temp),{'currentvar_temporal',currentvar_temporal},{'initvar_temporal',initvar_temporal});                
        end
        
        
    end    
   
   %t=1:1:nodes_for_experiment;
   inds=find(failed_users_current==0);
   
   %number_of_train_data_for_selected_users=length(find(ismember(data.nodes,users_top(1:1:nodes_for_experiment))));
   %number_of_test_data_for_selected_users=length(find(ismember(test.nodes,users_top(1:1:nodes_for_experiment))));
   
   number_of_train_data_for_selected_users=length(find(ismember(data.nodes,users_top(inds))));
   number_of_test_data_for_selected_users=length(find(ismember(test.nodes,users_top(inds))));
   
   temporal_loglikelihood_on_train_for_diffrent_data_sets(train_set)=sum(log_likelihood_temporal_current_trainset(:,end))/number_of_train_data_for_selected_users;
   temporal_optimization_time_on_train_for_diffrent_data_sets(train_set)=sum(optimization_time_temporal_current_trainset(:,end));
    
   temporal_loglikelihood_on_test_for_diffrent_data_sets(train_set)=sum(log_likelihood_temporal_on_test_current_trainset(:,end))/number_of_test_data_for_selected_users;


   
   spatial_loglikelihood_on_train_for_diffrent_data_sets(train_set)=sum(log_likelihood_spatial_with_entropy(inds,end))./number_of_train_data_for_selected_users;
   spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit(train_set)=sum(min(log_likelihood_spatial_with_entropy(inds,2:end),[],2))./number_of_train_data_for_selected_users;
   
   
   spatial_loglikelihood_on_test_for_diffrent_data_sets(train_set)=sum(log_likelihood_on_test_spatial_with_entropy(inds,end))/number_of_test_data_for_selected_users;
   spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit(train_set)=sum(min(log_likelihood_on_test_spatial_with_entropy(inds,2:end),[],2))/number_of_test_data_for_selected_users;
  

   %%failed users for current train_set
   title_temp=strcat('failed_users_train_set_',num2str(train_set),'.mat');      
   save(fullfile(pwd,'Results/Real',folder_name,title_temp),'failed_users_current');

     
end
%% final results part temporal
if(problem_number==1 || problem_number==3)
    
     plot(dataset_size,temporal_loglikelihood_on_test_for_diffrent_data_sets);
     title('temporal_loglikelihood_on_test_for_diffrent_data_sets');    
     file_name=fullfile(pwd,'Results/Real',folder_name,'temporal_loglikelihood_on_test_for_diffrent_data_sets');                             
     print(file_name,'-dpng');
     close 

     title_temp=strcat('temporal_evaluations','.mat');      
     save(fullfile(pwd,'Results/Real',folder_name,title_temp),'temporal_loglikelihood_on_test_for_diffrent_data_sets','temporal_loglikelihood_on_train_for_diffrent_data_sets');
end

%% final result part spatial
if(problem_number==2 || problem_number==3)
    
     plot(dataset_size,spatial_loglikelihood_on_test_for_diffrent_data_sets);
     title('spatial_loglikelihood_on_test_for_diffrent_data_sets');    
     file_name=fullfile(pwd,'Results/Real',folder_name,'spatial_loglikelihood_on_test_for_diffrent_data_sets');             
     print(file_name,'-dpng');
     close 
     
     
     plot(dataset_size,spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit);
     title('spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit');    
     file_name=fullfile(pwd,'Results/Real',folder_name,'spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit');             
     print(file_name,'-dpng');
     close 
     
     title_temp=strcat('spatial_evaluations','.mat');      
     save(fullfile(pwd,'Results/Real',folder_name,title_temp),'spatial_loglikelihood_on_test_for_diffrent_data_sets','spatial_loglikelihood_on_train_for_diffrent_data_sets','spatial_loglikelihood_on_test_for_diffrent_data_sets_unoverfit','spatial_loglikelihood_on_train_for_diffrent_data_sets_unoverfit','failed_users')
     
end

