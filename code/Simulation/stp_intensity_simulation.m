%% Intensity of Spatio-Temporal Model


function I = stp_intensity_simulation(model, events, t,integ,method)
    events_temp=events;

    events.times=events.times(events_temp.times<=t & events_temp.times~=0 );
    events.nodes=events.nodes(events_temp.times<=t & events_temp.times~=0);
    events.categories=events.categories(events_temp.times<=t & events_temp.times~=0);
    
    past_events_number=length(events.times);

    number_of_first_events_to_consider=length(events.times);


	I = model.mu;
    
    if(integ==1)
    I=model.mu*t;
    end
  
    if(integ==1)    
       for i= 1:number_of_first_events_to_consider
               ui = events.nodes(i);
               ti = events.times(i);
               ci=events.categories(i);
               if(i<=number_of_first_events_to_consider-past_events_number)
                  t=events.times(i+past_events_number); 
               end
              
              if(strcmp(method,'temporal_exp')==1)
              I(ui,ci) = I(ui,ci) + model.beta_of_users(ui)*g_exp(t,ti,integ,model);
              else
                  if(strcmp(method,'temporal_social')==1)
                    I(:,ci)=I(:,ci)+model.a_temporal(ui,:)*g_exp(t,ti,integ,model);
                  else
                        if(strcmp(method,'temporal_simple')==1)
                                I(ui,ci) = I(ui,ci) + model.beta_of_users(ui)*g(t,ti,integ,model);                           
                        end
                   end
                  
                  
              end
          end
    end

    if(integ==0)    

        for i=max(1,number_of_first_events_to_consider-(past_events_number+1)):number_of_first_events_to_consider
               ui = events.nodes(i);
               ti = events.times(i);
               ci=events.categories(i);
            if(strcmp(method,'temporal_exp')==1)
              I(ui,ci) = I(ui,ci) + model.beta_of_users(ui)*g_exp(t,ti,integ,model);
              else
                  if(strcmp(method,'temporal_social')==1)
                    I(:,ci)=I(:,ci)+model.a_temporal(ui,:)*g_exp(t,ti,integ,model);
                  else
                        if(strcmp(method,'temporal_simple')==1)
                            I(ui,ci) = I(ui,ci) + model.beta_of_users(ui)*g(t,ti,integ,model);
                        end                        
                   end
                                   
            end
       end
    end

end

