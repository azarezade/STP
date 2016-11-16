load('4sq');

mkdir([pwd,'/Results/real/location'],'offline');
mkdir([pwd,'/Results/real/location/offline'],'dists');

users_top=users_top(1:1000);

users_top_backup=users_top;

nodes_for_experiment=length(users_top);

location_accuracy_for_diffrent_stp_based_methods=zeros(length(algorithms)*3,number_of_simulation_iters);
location_top3_list_accuracy_for_diffrent_stp_based_methods=zeros(length(algorithms)*3,number_of_simulation_iters);
location_top10_list_accuracy_for_diffrent_stp_based_methods=zeros(length(algorithms)*3,number_of_simulation_iters);
location_top25_list_accuracy_for_diffrent_stp_based_methods=zeros(length(algorithms)*3,number_of_simulation_iters);
location_sum_of_probabilities_for_diffrent_stp_based_methods=zeros(length(algorithms)*3,number_of_simulation_iters);

model_for_use=model;

for i=1:1:3    
    for version=1:1:1 %% 1 is true version, 2 is base with neighs and 3 is base without neighs
        method_index=(i-1)*3+version;
        for iter=1:1:number_of_simulation_iters
            disp(i);
            problem_unique_name=algorithms{i};

            folder_name=strcat('spatial_',problem_unique_name,'_real');

            %% model creation
            train_days=dataset_size_in_days(train_set_number);
            test_days=test_size_in_days;

            model_for_simulation=model;
            model_for_simulation.eta=zeros(model.nodes,model.categories); 
            %model_for_simulation.eta=model.eta;

           for j=1:1:nodes_for_experiment
                u=users_top(j); 
                title_temp=strcat('parameters_user_',num2str(u),'_trainset_',num2str(train_set_number),'.mat');         
                file_name=fullfile(pwd,'Results','real',folder_name,title_temp);
                load(file_name);

                indx_u=find(model_for_simulation.a(:,u));
                if(version==2 || version==3)
                    model_for_simulation.a(indx_u,u)=5*randn(size(currentvar_spatial(1:length(indx_u))));
                else
                    model_for_simulation.a(indx_u,u)=currentvar_spatial(1:length(indx_u));
                end

                    model_for_simulation.eta(u,:)=currentvar_spatial(length(indx_u)+1:end)';

           end

           if(version==3)
                model_for_simulation.a=eye(size(model_for_simulation.a)).*model_for_simulation.a;
           end
           
            
            %% event simulation
            t0=events.times(end)-day2hour(test_days);
            past_events_start_time=events.times(end)-(day2hour(test_days)+day2hour(train_days));

            train_events_inds=find(events.times>=past_events_start_time & events.times<t0);
            test_events_inds=find(events.times>=t0);

            train_events.times=events.times(train_events_inds);
            train_events.nodes=events.nodes(train_events_inds);
            train_events.categories=events.categories(train_events_inds);
            train_events.locations=events.locations(train_events_inds);

            test_events.times=events.times(test_events_inds);
            test_events.nodes=events.nodes(test_events_inds);
            test_events.categories=events.categories(test_events_inds);
            test_events.locations=events.locations(test_events_inds);

            predicted_events_locations=zeros(size(test_events.locations));
            predicted_top_3_lists=zeros(3,length(test_events.locations));
            predicted_top_10_lists=zeros(10,length(test_events.locations));
            predicted_top_25_lists=zeros(25,length(test_events.locations));
            location_sum_of_prob=zeros(size(test_events.locations));

            train_ind=length(train_events.times);
            train_ind=train_ind+1;
            %for loc_ind=1:1:length(predicted_events.locations)
            number_of_locs_to_consider=length(predicted_events_locations);
            users_to_be_consider_indices=find(ismember(test_events.nodes,users_top));
            %number_of_locs_to_consider=20;
            disp('start...')
            for loc_ind=1:1:number_of_locs_to_consider
                disp(strcat(num2str(loc_ind),'/',num2str(length(predicted_events_locations))));
                if(version==2 || version==3)
                [predicted_events_locations(loc_ind), dist]=sample_location(train_events,model_for_simulation,test_events.times(loc_ind),test_events.categories(loc_ind),test_events.nodes(loc_ind),problem_unique_name,48,0);
                else
                 [predicted_events_locations(loc_ind), dist]=sample_location(train_events,model_for_simulation,test_events.times(loc_ind),test_events.categories(loc_ind),test_events.nodes(loc_ind),problem_unique_name,48,0);                          
                end
                dist=dist/sum(dist);
                location_sum_of_prob(loc_ind)=dist(test_events.locations(loc_ind));
                [vals,inds]=sort(dist);

                predicted_top_3_lists(:,loc_ind)=inds(end-2:end);
                predicted_top_10_lists(:,loc_ind)=inds(end-9:end);
                predicted_top_25_lists(:,loc_ind)=inds(end-24:end);

                %train_events.times(train_ind)=test_events.times(loc_ind);
                %train_events.nodes(train_ind)=test_events.nodes(loc_ind);    
                %train_events.categories(train_ind)=test_events.categories(loc_ind);    
                %train_events.locations(train_ind)=predicted_events_locations(loc_ind);    

                %% concat the new simulated event to train events
                train_length=length(train_events.times);
                train_events.times(train_length+1)=test_events.times(loc_ind);
                train_events.nodes(train_length+1)=test_events.nodes(loc_ind);
                train_events.categories(train_length+1)=test_events.categories(loc_ind);
                if(update_mode==0)
                    train_events.locations(train_length+1)=predicted_events_locations(loc_ind); 
                else
                    train_events.locations(train_length+1)=test_events.locations(loc_ind); 
                end
                title_temp=strcat(strcat(problem_unique_name,'_',num2str(version),'_spatial_dist_for_location_',num2str(loc_ind)),'.mat');      
                save(fullfile(pwd,'Results/real/location/offline/dists',title_temp),'dist')
            end


            %% location accuracy
            trues=length(find(test_events.locations==predicted_events_locations));
            location_accuracy_for_diffrent_stp_based_methods(method_index,iter)=trues/number_of_locs_to_consider;

        %% list quality
            tops=[3 10 25];
            for t=1:1:length(tops)
                trues_list=0;
                top=tops(t);

                if(top==3)
                    predicted_top_x_list=predicted_top_3_lists;
                else
                    if(top==10)
                        predicted_top_x_list=predicted_top_10_lists;
                    else
                       if(top==25)
                           predicted_top_x_list=predicted_top_25_lists;
                       end
                    end
                end

                elite_users_inds=find(ismember(test_events.nodes,users_top));
                for e=1:1:length(elite_users_inds)
                    elem_ind=elite_users_inds(e);
                    if(ismember(test_events.locations(elem_ind),predicted_top_x_list(:,elem_ind)))
                        trues_list=trues_list+1;
                    end
                end

                if(top==3)
                          location_top3_list_accuracy_for_diffrent_stp_based_methods(method_index,iter)=trues_list/length(elite_users_inds);
                else if(top==10)
                          location_top10_list_accuracy_for_diffrent_stp_based_methods(method_index,iter)=trues_list/length(elite_users_inds);
                    else if(top==25)
                          location_top25_list_accuracy_for_diffrent_stp_based_methods(method_index,iter)=trues_list/length(elite_users_inds);
                        end
                    end
                end
            end

            location_sum_of_probabilities_for_diffrent_stp_based_methods(method_index,iter)=sum(location_sum_of_prob(elite_users_inds))/length(elite_users_inds);

        end
        title_temp=strcat(strcat(problem_unique_name,'_',num2str(version),'_spatial'),'.mat');      

        predicted_events_locations_elite=predicted_events_locations(elite_users_inds);
        predicted_top_3_lists_elite=predicted_top_3_lists(:,elite_users_inds);
        predicted_top_10_lists_elite=predicted_top_10_lists(:,elite_users_inds);
        predicted_top_25_lists_elite=predicted_top_25_lists(:,elite_users_inds);
        location_sum_of_prob_elite=location_sum_of_prob(elite_users_inds);
        test_location_elite=test_events.locations(elite_users_inds);

        save(fullfile(pwd,'Results/real/location/offline',title_temp),'predicted_events_locations_elite','predicted_top_3_lists_elite','predicted_top_10_lists_elite','predicted_top_25_lists_elite','location_sum_of_prob_elite','test_location_elite','elite_users_inds');

    end
end


title_temp=strcat(strcat('overall','_spatial'),'.mat');      
save(fullfile(pwd,'Results/real/location/offline',title_temp),'location_sum_of_probabilities_for_diffrent_stp_based_methods','location_accuracy_for_diffrent_stp_based_methods','location_top3_list_accuracy_for_diffrent_stp_based_methods','location_top10_list_accuracy_for_diffrent_stp_based_methods','location_top25_list_accuracy_for_diffrent_stp_based_methods');
     
