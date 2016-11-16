function [prob] = softmax(value, vect,zeros,beta )

denumerator=sum(exp(beta*vect))+zeros;
numirator=exp(beta*value);
prob=numirator./denumerator;
end

