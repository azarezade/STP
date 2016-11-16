function [ inv_A ] = approxinv( A )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[v,d] = eig(A);
ss = 0;
isl = 0;
for i = 1:length(v)
    if(abs(d(i,i))<1e-20)
        isl=1;
    end
end

for i=1:length(v)
    ei = d(i,i);
    if(isl==1)
        ei = ei + 1e-3;
    end
    ss = ss + (1/ei) * v(:,i)*v(:,i)';
end
inv_A = ss;

end

