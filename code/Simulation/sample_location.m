function [l, dist] = sample_location(events,model,t,category,u,method,window_frame,no_external_world)

speedup_for_simulation=0;
if(nargin>6)
    speedup_for_simulation=1;
end
    
%ngbs_u=model.outnetwork{u};
ngbs_u=find(model.a(:,u));

a_u=model.a(:,u);
eta_u=model.eta(u,:);


location_distribution=zeros(model.locations(category),1);

%potential_locations=unique(events.locations(events.times<t & events.categories==category & ismember(events.nodes,ngbs_u)));


for v_indice=0:1:length(ngbs_u)    
    %disp(v_indice);
    if(v_indice==0)
       v=0;
       locations=1:1:model.locations(category);
       
       if(speedup_for_simulation==1)
       %warning: speedup in offline experiments
       locations=events.locations(find(events.categories==category & events.times<t & events.times>t-window_frame));
       locations=unique(locations);
           if(no_external_world==1)
            continue;
           end
       end
    else
           v=ngbs_u(v_indice);
           locations=unique(events.locations(find(ismember(events.nodes,v) & events.categories==category)));
    end
    
    for l_indice=1:1:length(locations)
       l=locations(l_indice);
       %disp(l);
       %gamma_func_value=gamma_func_simulation(events,model,v,category,l_indice,t,exp(eta_u),exp(a_u),ngbs_u,method);
       gamma_func_value=gamma_func_simulation(events,model,v,category,l,t,exp(eta_u),exp(a_u),ngbs_u,method);
       
       location_distribution(l)= location_distribution(l)+gamma_func_value;       
    end
end


%a=full(model.a);
%ngbs_one=find(a(:,1)~=0);
%if(category==1 & ismember(u,ngbs_one)==1 )
%disp('hi');    
%end



l=discrete_sampler(location_distribution);
dist=location_distribution;
end
