if(real_data==0)

model=ModelGenerator(N,C,L, sp, max_mu,max_eta, max_a,max_beta,stationary);
model.max_mu=max_mu;%base rate of users for generate an event (N*1 array)
model.max_eta=max_eta;% orientation to choose new places in a category by a user (N*P matrix)
model.max_a=max_a;%connection weight in adjacency matrix
model.max_beta=max_beta;
else

model.a=sparse(adjacency_matrix);

model.a(logical(eye(size(model.a)))) = 1;

model.a_temporal=model.a; %% just for social method


model.categories=C;
model.nodes=N;
model.locations=L;
end


model.w=w;
model.sigma_gaussian=sigma_gaussian;
model.sigma_exponential=sigma_exponential;

model.sigma_location_exponential=sigma_location_exponential;
if(real_data==0)
   t0=0; 
   events=stp_simulator(model,t0,quantity,method_time,method_location);% overwrite events 
else    

    events_struct.nodes=events(:,1);
    events_struct.times=events(:,2);
    events_struct.categories=events(:,3);
    events_struct.locations=events(:,4);
    events=events_struct; 
end

if(unknown_adjacency==1)
    model.a=ones(size(model.a));
end

if(real_data==0)
save(fullfile(pwd, 'Code', 'Data','Synth',['erdos' '.mat']),'events','model')
else    
save(fullfile(pwd, 'Code', 'Data','Real',['4sq' '.mat']),'events','model')
end
