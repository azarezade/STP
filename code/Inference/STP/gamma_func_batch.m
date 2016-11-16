%% blah blah blah
function [gamma_value,numerator,denuminator,denuminator_sudo,W_uc ]= gamma_func_batch(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,w,c,l,t,eta_u,a_u,ngbs_u,method,batch_size)%% denuminator_modified and W_uc is applcable when v=0

%% speed consideration we use the code instead of full method name string
spatial_tik=0;
spatial_etk=0;
spatial_etk_period_consideration=0;
if(strcmp(method,'spatial_tik')==1)
    spatial_tik=1;
elseif(strcmp(method,'spatial_etk')==1)
    spatial_etk=1;
elseif(strcmp(method,'spatial_etk_period_consideration')==1)
    spatial_etk_period_consideration=1;
end


W_uc_matrix_spec_element=zeros(batch_size,1);
W_uc_matrix_sum=zeros(batch_size,1); % scalability assumptions don't allow us to do summation over above matrix

filtered_data_indices=find(data_u_neighs_cats{c}.times<t);

i_start=max(1,length(filtered_data_indices)-100);


nodes=data_u_neighs_cats{c}.nodes;
locations=data_u_neighs_cats{c}.locations;
times=data_u_neighs_cats{c}.times;


dic_neighs(ngbs_u)=1:1:length(ngbs_u);%% performance consideration

for i=i_start:1:length(filtered_data_indices)	
       filtered_data_indice=filtered_data_indices(i);
       node=nodes(filtered_data_indice);
       %node_ind=find(ngbs_u==node,1);
       node_ind=dic_neighs(node);
       loc=locations(filtered_data_indice);
       ti=times(filtered_data_indice);
       loc_status=(loc~=l);
       node_status=(node~=w);
       aggr_status=loc_status+node_status;
       if(aggr_status==0)
%                if(strcmp(method,'stil')==0)
                 if(spatial_etk==1)
                    for batch=1:1:batch_size 
                        a_u_current=a_u(:,batch);
                        W_uc_matrix_spec_element(batch)=W_uc_matrix_spec_element(batch)+a_u_current(node_ind)*exp(-model.sigma_location_exponential*(t-ti));
                    end
                 elseif(spatial_tik==1)
                     for batch=1:1:batch_size 
                        a_u_current=a_u(:,batch);
                        W_uc_matrix_spec_element(batch)=W_uc_matrix_spec_element(batch)+a_u_current(node_ind);
                     end
                 elseif(spatial_etk_period_consideration==1)
                     for batch=1:1:batch_size 
                        a_u_current=a_u(:,batch);
                        W_uc_matrix_spec_element(batch)=W_uc_matrix_spec_element(batch)+a_u_current(node_ind)*exp(-model.sigma_location_exponential*abs(t-model.w-ti));
                     end  
                 end
       end
          
      if(spatial_etk==1)
                for batch=1:1:batch_size
                    a_u_current=a_u(:,batch);
                    W_uc_matrix_sum(batch)=W_uc_matrix_sum(batch)+a_u_current(node_ind)*exp(-model.sigma_location_exponential*(t-ti));
                end
      elseif(spatial_tik==1)
                for batch=1:1:batch_size
                    a_u_current=a_u(:,batch);
                    W_uc_matrix_sum(batch)=W_uc_matrix_sum(batch)+a_u_current(node_ind);
                end
      elseif(spatial_etk_period_consideration==1)
                for batch=1:1:batch_size
                    a_u_current=a_u(:,batch);
                    W_uc_matrix_sum(batch)=W_uc_matrix_sum(batch)+a_u_current(node_ind)*exp(-model.sigma_location_exponential*(t-model.w-ti));
                end
      end
end

%events_c_indices=1:1:sum(find(data_c{c}.times<t,1));
events_c_indices=1:1:(find(data_c{c}.times>t,1)-1);

start_ind=max(1,length(events_c_indices)-10000); % a wider window for precision issues
events_c_indices=events_c_indices(start_ind:end);
%events_cl_indices=find(data.categories==c & data.locations==l & data.times<t & data.times>t-168);
events_cl_indices=find(data_c{c}.locations(events_c_indices(start_ind:end))==l );
events_cl_indices=events_cl_indices+(start_ind-1);


%% windowing on events


if(spatial_tik==0)  
    exponential_c=exp(-model.sigma_location_exponential*(t-data_c{c}.times(events_c_indices)));
    exponential_cl=exp(-model.sigma_location_exponential*(t-data_c{c}.times(events_cl_indices)));

else
%     exponential_c=length(data_c{c}.times(events_c_indices));
%     exponential_cl=length(data_c{c}.times(events_cl_indices));

     exponential_c=ones(size(data_c{c}.times(events_c_indices)));
     exponential_cl=ones(size(data_c{c}.times(events_cl_indices)));
     

end


loc_list=data_c{c}.locations(events_c_indices);

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
else
    numerator=zeros(batch_size,1);
    for batch=1:1:batch_size
        eta_u_current=eta_u(:,batch);
        numerator(batch)=eta_u_current(c)*prob;
    end
end

for batch=1:1:batch_size
    eta_u_current=eta_u(:,batch);
    denuminator=((eta_u_current(c)+W_uc));
end

gamma_value=numerator./denuminator;


end