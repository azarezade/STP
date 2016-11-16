function d = sample_user(Is)
% Inputs:
%   Is: a N*P matrix, containing the product intensities for different users
% Outputs:
%   d: the sampled user to do event

    u_Is = sum(Is,2);    
    u = rand()*sum(u_Is);
    sumIs = 0;
    for d=1:length(u_Is)
       sumIs = sumIs + u_Is(d);
       if sumIs >= u
           break;
       end
    end
end