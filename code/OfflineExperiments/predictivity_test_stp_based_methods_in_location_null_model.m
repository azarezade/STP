load('4sq');

mkdir([pwd,'/Results/real/location'],'offline');
mkdir([pwd,'/Results/real/location/offline'],'dists');
events_arr(:,1)=events.nodes;
events_arr(:,2)=events.times;
events_arr(:,3)=events.categories;
events_arr(:,4)=events.locations;

dataset_size_in_days=[52 42 28 21 14 7];
test_size_in_days=14;

train_set_number=1;
update_mode=1;
users_top=find_top_users(events_arr,1000);
users_top=users_top(1:1000);

users_top_backup=users_top;

nodes_for_experiment=length(users_top);
model_for_use=model;

accuracy=0;


folder_name=strcat('spatial_','etk','_real');

%% model creation
train_days=dataset_size_in_days(train_set_number);
test_days=test_size_in_days;

model_for_simulation=model;
model_for_simulation.eta=zeros(model.nodes,model.categories); 
%model_for_simulation.eta=model.eta;

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

train_ind=length(train_events.times);
train_ind=train_ind+1;
%for loc_ind=1:1:length(predicted_events.locations)
number_of_locs_to_consider=length(predicted_events_locations);
users_to_be_consider_indices=find(ismember(test_events.nodes,users_top));
%number_of_locs_to_consider=20;
disp('start...')
for loc_ind=1:1:number_of_locs_to_consider
    disp(loc_ind);
    node=test_events.nodes(loc_ind);
    ngbs_u=find(model.a(:,node)~=0);
    possible_locs_inds=find(train_events.categories==test_events.categories(loc_ind) & ismember(train_events.nodes,ngbs_u));
    possible_locs=unique(train_events.locations(possible_locs_inds));
    
    if(length(possible_locs)==0)
            possible_locs_inds=find(train_events.categories==test_events.categories(loc_ind));
            possible_locs=unique(train_events.locations(possible_locs_inds));
    end
    predicted_events_locations(loc_ind)=possible_locs(ceil(rand()*length(possible_locs)));

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
end


%% location accuracy
elite_users_inds=find(ismember(test_events.nodes,users_top));



predicted_events_locations_elite=predicted_events_locations(elite_users_inds);
test_location_elite=test_events.locations(elite_users_inds);
accuracy=length(find(predicted_events_locations_elite==test_location_elite))/length(elite_users_inds);
title_temp=strcat('null','_spatial','.mat');      
save(fullfile(pwd,'Results/real/location/offline'),title_temp,'accuracy');
     
