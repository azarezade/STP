function [ f_val,g_val,h_val] = f_objective_with_hessian_temporal(f,g,h,x)

f_val=f(x);
g_val=g(x);
h_val=h(x);
end

