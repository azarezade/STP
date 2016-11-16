function entropy_val = entropy_calculator(model,data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,u,a_u,eta_u,method)
%ESTEP Summary of this function goes here
%   Detailed explanation goes here

entropy_val=0;

ngbs_u = find(data.adj(:,u));
ngbs_u_num = length(ngbs_u);

Z=zeros(length(data_u.times),model.nodes+1);    

 for i=1:1:length(data_u.times)         
    for v=0:1:ngbs_u_num
        
        element_v=0;
        if(v~=0)
            element_v=ngbs_u(v);
        end
        Z(i,element_v+1)=gamma_func(data,data_c,data_u,data_u_neighs,data_u_cats,data_u_neighs_cats,model,element_v,data_u.categories(i),data_u.locations(i),data_u.times(i),exp(eta_u),exp(a_u),ngbs_u,method);           
    end
    normal_factor=sum(Z(i,:));
    Z(i,:)=Z(i,:)/normal_factor;
 end

 for i=1:1:length(data_u.times)         
    for v=0:1:ngbs_u_num
        element_v=0;
        if(v~=0)
            element_v=ngbs_u(v);
        end           

        if(Z(i,element_v+1)~=0)
            entropy_val=entropy_val-(Z(i,element_v+1)*log(Z(i,element_v+1)));
        end
    end
 end     

    
end