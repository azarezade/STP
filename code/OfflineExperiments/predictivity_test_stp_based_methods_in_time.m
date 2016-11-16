load('4sq');

mkdir([pwd,'/Results/Real/time'],'offline');
    
users_top=users_top(1:1000);

users_top_backup=users_top;

nodes_for_experiment=length(users_top);

simple_mean=zeros(1000,1);
exp_mean=zeros(1000,1);
social_mean=zeros(1000,1);

removed=0;
for i=1:1:length(algorithms)
    time_prediction_distance_for_diffrent_stp_based_methods=zeros(length(users_top_backup),number_of_simulation_iters);
    for k=1:1:length(users_top_backup)
        disp(k);
        current_user=users_top_backup(k);
    
        for iter=1:1:number_of_simulation_iters
             
            problem_unique_name=algorithms{i};
            folder_name=strcat('temporal_',problem_unique_name,'_real');

            %% model creation
            train_days=dataset_size_in_days(train_set_number);
            test_days=test_size_in_days;

            model_for_simulation=model;
            model_for_simulation.mu=zeros(model.nodes,model.categories);
            model_for_simulation.beta_of_users=zeros(1,model.nodes);
            model_for_simulation.a_temporal=model.a_temporal;
            model_for_simulation.eta=rand(model.nodes,model.categories);

            %for j=1:1:nodes_for_experiment
               %u=users_top(k); 
               %u=current_user;
              
               title_temp=strcat('parameters_user_',num2str(current_user),'_trainset_',num2str(train_set_number),'.mat');         
               file_name=fullfile(pwd,'Results','Real',folder_name,title_temp);
               load(file_name);
               if(strcmp(problem_unique_name,'temporal_social')==1)

                   model_for_simulation.mu(current_user,:)=currentvar_temporal(1:model.categories);
                   indx_u=find(model_for_simulation.a_temporal(:,current_user));
                   model_for_simulation.a_temporal(indx_u,current_user)=currentvar_temporal(model.categories+1:model.categories+indx_u);

               else           
                   model_for_simulation.mu(current_user,:)=currentvar_temporal(1:model.categories);
                   model_for_simulation.beta_of_users(current_user)=currentvar_temporal(model.categories+1);
               end
               indx_u=find(model_for_simulation.a(:,current_user));

       

            %% event simulation
            t0=events.times(end)-day2hour(test_days);
            past_events_start_time=events.times(end)-(day2hour(test_days)+day2hour(train_days));

            train_events_inds=find(events.times>=past_events_start_time & events.times<t0 & events.nodes==current_user);
            test_events_inds=find(events.times>=t0 & events.nodes==current_user);

            train_events.times=events.times(train_events_inds);
            train_events.nodes=events.nodes(train_events_inds);
            train_events.categories=events.categories(train_events_inds);
            train_events.locations=events.locations(train_events_inds);

            test_events.times=events.times(test_events_inds);
            test_events.nodes=events.nodes(test_events_inds);
            test_events.categories=events.categories(test_events_inds);
            test_events.locations=events.locations(test_events_inds);

            quantity=struct;
            quantity.type='time';
            if(length(test_events.times)==0)
                removed=removed+1;
                continue;
            end
            quantity.value=test_events.times(end);
            

            simulated_events=stp_simulator(model_for_simulation, t0,quantity,problem_unique_name,'no_location',train_events,1);
            %test_events_of_selected_users_inds=find(ismember(test_events.nodes,users_top(1:1:nodes_for_experiment)));
            test_events_arr=[];
            test_events_arr(:,1)=test_events.nodes;
            test_events_arr(:,2)=test_events.times;
            test_events_arr(:,3)=test_events.categories;
            test_events_arr(:,4)=test_events.locations;


            simulated_events_of_selected_users_inds=find(ismember(simulated_events.nodes,current_user)); %% mohkamkari


            simulated_events_of_selected_users=[];
            simulated_events_of_selected_users(:,1)=simulated_events.nodes(simulated_events_of_selected_users_inds);
            simulated_events_of_selected_users(:,2)=simulated_events.times(simulated_events_of_selected_users_inds);    
            simulated_events_of_selected_users(:,3)=simulated_events.categories(simulated_events_of_selected_users_inds);    
            simulated_events_of_selected_users(:,4)=simulated_events.locations(simulated_events_of_selected_users_inds);


            %% time correlation
            for c=1:1:10
            test_events_arr_temp=test_events_arr(find(test_events_arr(:,3)==c),:);
            simulated_events_of_selected_users_temp=simulated_events_of_selected_users(find(simulated_events_of_selected_users(:,3)==c),:);
            [count_real, x_real]=hist(test_events_arr_temp(:,2),number_of_bins_time);
            count_sim=hist(simulated_events_of_selected_users_temp(:,2),x_real);
            if(size(count_sim,1)>size(count_sim,2))
                count_sim=count_sim';
            end

            val=sum(abs(count_real(1:28)-count_sim(1:28)));
            time_prediction_distance_for_diffrent_stp_based_methods(k,iter)=time_prediction_distance_for_diffrent_stp_based_methods(k,iter)+val;
            end
            %time_prediction_distance_for_diffrent_stp_based_methods(k,iter)=time_prediction_distance_for_diffrent_stp_based_methods(k,iter)/length(test_events_inds);
        end
    end
    
    
    time_prediction_distance_for_diffrent_stp_based_methods_mean=mean(time_prediction_distance_for_diffrent_stp_based_methods,2);
    time_prediction_distance_for_diffrent_stp_based_methods_var=var(time_prediction_distance_for_diffrent_stp_based_methods,0,2);
        

    
    title_temp=strcat(problem_unique_name,'.mat'); 
    save(fullfile(pwd,'Results/real/time/offline',title_temp),'time_prediction_distance_for_diffrent_stp_based_methods','time_prediction_distance_for_diffrent_stp_based_methods_mean','time_prediction_distance_for_diffrent_stp_based_methods_var')
    
    if(strcmp(algorithms{i},'simple'))
        simple_mean=time_prediction_distance_for_diffrent_stp_based_methods_mean;    
    end
    if(strcmp(algorithms{i},'exp'))
        exp_mean=time_prediction_distance_for_diffrent_stp_based_methods_mean;
    end
    
    if(strcmp(algorithms{i},'social'))
        social_mean=time_prediction_distance_for_diffrent_stp_based_methods_mean;
    end

    
end
tritary_count=count_min([simple_mean exp_mean social_mean]);
pair_wise_simple_exp=count_min([simple_mean exp_mean]);
pair_wise_simple_social=count_min([simple_mean social_mean]);
pair_wise_exp_social=count_min([exp_mean social_mean]);
removed=removed/3000;
tritary_count=tritary_count-removed;
pair_wise_exp_social=pair_wise_exp_social-removed;
pair_wise_simple_social=pair_wise_simple_social-removed;
pair_wise_simple_exp=pair_wise_simple_exp-removed;
title_temp=strcat('overall_compare','.mat'); 
save(fullfile(pwd,'Results/real/time/offline',title_temp),'tritary_count','pair_wise_simple_exp','pair_wise_simple_social','pair_wise_exp_social');
    