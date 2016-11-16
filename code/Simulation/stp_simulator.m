%% Simulator of Spatio-Temporal Model
% blah blah bah

function events = stp_simulator(model, t0,quantity,method_time,method_location,events,just_simulation_of_times)

max_beta=max(max(model.beta_of_users));
max_mu=max(max(model.mu));

if nargin < 6
    events = struct;
    init_size = 10000;
    events.times    = zeros(init_size,1);
    events.nodes    = zeros(init_size,1);
    events.categories = zeros(init_size,1);
    events.locations=zeros(init_size,1);
    n = 0;
else
    n = length(find(events.times < t0));%%  I didn't understand
end

t = t0;
iter = 0;
number_of_simulated_points=0;
if(strcmp(method_time,'temporal_simple')==1)
    periodic=1;
else
    periodic=0;
end

while ( (t <quantity.value && strcmp(quantity.type,'time')==1) || (number_of_simulated_points<quantity.value && strcmp(quantity.type,'number')==1) )  


    val=0;
    I=stp_intensity_simulation(model, events, t,0,method_time); %% simple and stil are same
    if(periodic==1)          
        past_times=events.times(find(events.times~=0 & events.times<=t));
        times_diff=t-(past_times);
        times_diff_unit=round(times_diff/model.w);
        times_diff_unit=times_diff_unit(max(1,end-end):end);
        %times_diff_unit=times_diff_unit+1;
        val=max_beta*sum(exp(-times_diff_unit))+max_mu*model.nodes*model.categories;
    end

    
  
    % Calculate the overal intensity of each node to generate events
    u_Is = sum(I,2);

    sumI = sum(u_Is)+val;
    
    
    t = t+exprnd(1./sumI);
    iter = iter + 1;
    if(mod(iter,100)==0) 
    %    disp(['(events so far:', num2str(n),', time so far:', num2str(t), ')']);
    end
    
    if ( (t>=quantity.value && strcmp(quantity.type,'time')==1) || (number_of_simulated_points>quantity.value && strcmp(quantity.type,'number')==1 ) ) 
        break;
    end

    Is = stp_intensity_simulation(model, events, t,0,method_time);

    
    sumIs = sum(sum(Is,2));

    u = rand();
    %%
    % decides to generate event or not
    if(u*sumI<sumIs)
        %disp(strcat('number_of_simulated_points: ',num2str(number_of_simulated_points)));
        %disp(t);
        %%
        % sample the user generated the event
        u = sample_user(Is);
        %%
        % sample the category
        
        c = sample_category(I(u,:));
        
        % sample the location
        if(just_simulation_of_times==1)
        l=1;
        else
        l=sample_location(events,model,t,c,u,method_location);
        end
        
        
        if n == length(events.times)
            tmp = events.times;
            events.times = zeros(2*n,1);
            events.times(1:n) = tmp;
            tmp = events.nodes;
            events.nodes = zeros(2*n,1);
            events.nodes(1:n) = tmp;
            %
            tmp = events.categories;
            events.categories = zeros(2*n,1);
            events.categories(1:n) = tmp;
            
            tmp = events.locations;
            events.locations = zeros(2*n,1);
            events.locations(1:n) = tmp;
            
            
        end
        n = n + 1;
        
            
        events.times(n) = t;
        events.nodes(n) = u;
        events.categories(n) = c;
        events.locations(n)=l;
        number_of_simulated_points=number_of_simulated_points+1;
        
        if(mod(number_of_simulated_points,1000)==0)
            events.times=events.times(1:n);
            events.nodes=events.nodes(1:n);
            events.categories=events.categories(1:n);
            events.locations=events.locations(1:n);                        
            file=fullfile(pwd, 'Code', 'Data','Synth',['erdos' num2str(number_of_simulated_points) '.mat']);
            save(file,'events','model');
        end
        
    end
end


inds=find(events.times>t0);
events.times=events.times(inds);
events.nodes=events.nodes(inds);
events.categories=events.categories(inds);
events.locations=events.locations(inds);

end
