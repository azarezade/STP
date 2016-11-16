%% priodic gaussian kernel
function value = g(t,ti,integral,model)


% inputs:
%     integral:if integral set to one the value is the integral of PGK from ti to t.
w=model.w;
sigma=model.sigma_gaussian;

value=0;

    
    
    if(integral==0)            
        k=round((t-ti)/w);
        value=exp(-((t-ti-(k*w))^2)/(2*sigma^2))*exp(-k);
        
    else

        number_of_terms=floor((t-(ti+w/2))/w);
        if(number_of_terms>0)
            series_sum=exp(-1)*(1-exp(-(number_of_terms)))/(1-exp(-1));
            %value=value+series_sum*2*(normcdf(w/2,0,sigma)-0.5);
            value=value+series_sum*2*(normcdf(w/2,0,sigma)-0.5);
            %value=value+exp(-(final_k))*((normcdf(t-ti,(final_k)*w,sigma)-normcdf((2*(final_k)-1)*w/2,(final_k)*w,sigma)));
        end
        
        final_k=number_of_terms+1;
        
        if(number_of_terms>=0)        
        value=value+exp(-(final_k))*((normcdf(t-ti,(final_k)*w,sigma)-normcdf((2*(final_k)-1)*w/2,(final_k)*w,sigma)));
        end
        

        if(number_of_terms>=0)
            value_from_self_ex=normcdf(w,0,sigma)-0.5;
        else
           value_from_self_ex=normcdf(t-ti,0,sigma)-0.5; 
        end
        

        value=value+value_from_self_ex;

        value=sigma*2.505992817228*value;
    end

     

end

