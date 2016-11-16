%% Intensity of Spatio-Temporal Model
% This function calculates the intensity of each user at time t given n
% previous events in the STP model.
%
% *Inputs*:
%   model: a model containing the a and $$\mu$$ and structure
%   events: the set of events 
%   t: the time for which we want to calculate Intensity
%   n: the number of  first events we use to calculate the intensity at t
%   integ: integ==1 for integral and integ==0 for normal.
%   
%
% *Outputs*:
%   I: a N*P matrix showing the intensity of nodes for each product at time
%      t. The i'th row shows the intensity of node i at time t for
%      different  products.

function I = stp_intensity(model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats, t,integ,u,cat,method)
    events_temp=data;
    if(strcmp(method,'temporal_social')==0)
    past_events_number=100;        
    events_temp.times=data_u_cats{cat}.times(data_u_cats{cat}.times<t);
    events_temp.nodes=data_u_cats{cat}.nodes(data_u_cats{cat}.times<t);
    events_temp.categories=data_u_cats{cat}.categories(data_u_cats{cat}.times<t);
    
    else
            past_events_number=100;        
            events_temp.times=data_u_neighs_cats{cat}.times(data_u_neighs_cats{cat}.times<t);
            events_temp.nodes=data_u_neighs_cats{cat}.nodes(data_u_neighs_cats{cat}.times<t);
            events_temp.categories=data_u_neighs_cats{cat}.categories(data_u_neighs_cats{cat}.times<t); 
        
    end
    
    data=events_temp;


    number_of_first_events_to_consider=length(data.times);

    
    %w=model.w;
    
	I = model.mu(u,cat);
    
    if(integ==1)
    I=model.mu(u,cat)*t;
    end
    

temporal_simple=0;
temporal_exp=0;
temporal_social=0;
if(strcmp(method,'temporal_simple')==1)
    temporal_simple=1;
else if(strcmp(method,'temporal_exp')==1)
        temporal_exp=1;
    elseif(strcmp(method,'temporal_social')==1)
            temporal_social=1;
    end
end
        
nodes=data.nodes;
times=data.times;

if(integ==1)    
   for i= 1:number_of_first_events_to_consider
           ui = nodes(i);
           ti = times(i);
           %cat=categories(i);
           if(i<=number_of_first_events_to_consider-past_events_number)
              t=data.times(i+past_events_number); 
           end
            if(temporal_exp==1)
              %I(ui,cat) = I(ui,cat) + model.beta_of_users(ui)*g_exp(t,ti,integ,model);
               I = I + model.beta_of_users(ui)*g_exp(t,ti,integ,model); 
            else
                  if(temporal_social==1)
                    %I(:,cat)=I(:,cat)+model.a_temporal(ui,:)*g_exp(t,ti,integ,model);
                    I=I+model.a_temporal(ui,u)*g_exp(t,ti,integ,model);
                  else
                        if(temporal_simple==1)
                            %I(ui,cat) = I(ui,cat) + model.beta_of_users(ui)*g(t,ti,integ,model,1);
                            I = I + model.beta_of_users(ui)*g(t,ti,integ,model);
                        end
                        
                  end
             end
          %I(ui,ci) = I(ui,ci) + model.beta_of_users(ui)*g(events.tmax,ti,integ,model);
   end
end

if(integ==0)    

    for i=max(1,number_of_first_events_to_consider-(past_events_number+1)):number_of_first_events_to_consider
           ui = nodes(i);
           ti = times(i);
           %cat= categories(i);
            if(temporal_exp==1)
              %I(ui,cat) = I(ui,cat) + model.beta_of_users(ui)*g_exp(t,ti,integ,model);
               I = I + model.beta_of_users(ui)*g_exp(t,ti,integ,model); 
            else
                  if(temporal_social==1)
                    %I(:,cat)=I(:,cat)+model.a_temporal(ui,:)*g_exp(t,ti,integ,model);
                    I=I+model.a_temporal(ui,u)*g_exp(t,ti,integ,model);
                  else
                        if(temporal_simple==1)
                            %I(ui,cat) = I(ui,cat) + model.beta_of_users(ui)*g(t,ti,integ,model,1);
                            I = I + model.beta_of_users(ui)*g(t,ti,integ,model);
                        end
                        
                  end
             end 
   end
end



end

