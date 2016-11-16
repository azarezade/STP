function [cat, local_id ] = global2locallocid(model,global_id)
%LOCAL2GLOBALLOCID Summary of this function goes here
%   Detailed explanation goes here

L_accum=zeros(1,model.categories+1);

for i=1:1:model.categories
   L_accum(i+1)=L_accum(i)+model.locations(i); 
end


for i=2:1:11
    if(global_id<=L_accum(i))
        cat=i-1;
        local_id=global_id-L_accum(i-1);
        break;
    end
end

end

