
function [gamma_value,numerator,denuminator,denuminator_sudo,W_uc,coeff_vector ]= gamma_func_simulation(data,model,w,c,l,t,eta_u,a_u,ngbs_u,method)%% denuminator_modified and W_uc is applcable when v=0

cats_number=model.categories;
coeff_vector=zeros(1,length(ngbs_u)+cats_number);


W_uc_matrix_spec_element=0;
W_uc_matrix_sum=0; % scalability assumptions don't allow us to do summation over above matrix


inds_ct=find(data.categories==c & data.times<t);

datanew=data;

datanew.times=data.times(inds_ct);
datanew.categories=data.categories(inds_ct);
datanew.locations=data.locations(inds_ct);
datanew.nodes=data.nodes(inds_ct);    
filtered_data_indices=find(ismember(datanew.nodes,ngbs_u));    
filtered_data_indices=filtered_data_indices(1:min(length(filtered_data_indices),100));

for i=1:1:length(filtered_data_indices)	
       %disp(length(filtered_data_indices))
       
       node=datanew.nodes(filtered_data_indices(i));
       node_ind=find(ngbs_u==node);
       loc=datanew.locations(filtered_data_indices(i));
       ti=datanew.times(filtered_data_indices(i));
       if(node==w && loc==l)
          if(strcmp(method,'spatial_tik')==0)  
                W_uc_matrix_spec_element=W_uc_matrix_spec_element+a_u(node_ind)*exp(-model.sigma_location_exponential*(t-ti));
          else
                W_uc_matrix_spec_element=W_uc_matrix_spec_element+a_u(node_ind);  
          end
       end
          
          
      if(strcmp(method,'spatial_tik')==0)  
                W_uc_matrix_sum=W_uc_matrix_sum+a_u(node_ind)*exp(-model.sigma_location_exponential*(t-ti));
       
                coeff_vector(node_ind)=coeff_vector(node_ind)+exp(-model.sigma_location_exponential*(t-ti));
      else
                W_uc_matrix_sum=W_uc_matrix_sum+a_u(node_ind);
       
                coeff_vector(node_ind)=coeff_vector(node_ind)+1; 
      end

       
end

events_c_indices=1:1:length(inds_ct);
events_cl_indices=find(datanew.locations==l);



      if(strcmp(method,'spatial_tik')==0)  
        exponential_c=exp(-model.sigma_location_exponential*(t-datanew.times(events_c_indices)));
        exponential_cl=exp(-model.sigma_location_exponential*(t-datanew.times(events_cl_indices)));
      else
        exponential_c=length(events_c_indices);
        exponential_cl=length(events_cl_indices);
      end




loc_list=datanew.locations(events_c_indices);

[a_t,~,c_t] = unique(loc_list);
out = [a_t, accumarray(c_t,exponential_c)];

if(isempty(out)==0)
prob=softmax(sum(exponential_cl),out(:,2)',model.locations(c)-size(out,1),0.5);
else
prob=softmax(sum(exponential_cl),0,model.locations(c)-1,0.5);    
end


W_uc=W_uc_matrix_sum;

if(w>=1)
    numerator=W_uc_matrix_spec_element;
    
    
    denuminator=(eta_u(c)+W_uc);
    
    denuminator_sudo=denuminator; %% just to assign something!!
else
    

    numerator=eta_u(c)*prob;
    denuminator=((eta_u(c)+W_uc));

    denuminator_sudo=(eta_u(c)+W_uc);
    
    
end

gamma_value=numerator/denuminator;

end