%% this function return users with most events as top user
function [ modes ] = find_top_users( events,number_of_tops_to_return )
a = unique(events(:,1));
out = [a,histc(events(:,1),a)];
out_final=sortrows(out,-2);
modes=out_final(1:number_of_tops_to_return,1);
end

