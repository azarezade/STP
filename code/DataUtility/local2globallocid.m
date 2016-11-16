function [ global_id ] = local2globallocid(model, cat,local_id)
%LOCAL2GLOBALLOCID Summary of this function goes here
%   Detailed explanation goes here

L_accum=zeros(1,model.categories+1);

for i=1:1:model.categories
   L_accum(i+1)=L_accum(i)+model.locations(i); 
end

global_id=(L_accum(cat)+local_id);

end

