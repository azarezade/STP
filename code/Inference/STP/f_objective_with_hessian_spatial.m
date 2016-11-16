function [ f_val,g_val,h_val] = f_objective_with_hessian_spatial(f,g,h,x,Z)

f_val=f(x,Z);
g_val=g(x,Z);
h_val=h(x,Z);
end

