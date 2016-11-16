function c = sample_category(user_Is)
% This function samples a category for a user given his product intensities
% Inputs:
%   user_Is: a P*1 vector containing different intensities for a user where
%            P is the number of products.
%   exp_coeff: the parameter setting the exponential coefficient
% Outputs:
%   p: the sampled category

%     exp_Is = exp(exp_coeff * user_Is);
%     u = rand()*sum(exp_Is);
%     sumIs = 0;
%     for p=1:length(exp_Is)
%        sumIs = sumIs + exp_Is(p);
%        if sumIs >= u
%            break;
%        end
%     end

    c=discrete_sampler(user_Is/sum(user_Is));

end