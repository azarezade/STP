function x = discrete_sampler(list)

if(sum(list)==0)
    list=list+1;
end

list=list./(sum(list));

cdf=zeros(size(list));

cdf(1)=list(1);
    for i=2:1:length(list)
        cdf(i)=cdf(i-1)+list(i);
    end

rnd=rand;
choosed_rnd=0;
for i=1:1:length(cdf)
   if(rnd<=cdf(i))
       choosed_rnd=i;
       break;
   end
end

x=choosed_rnd;

end

