%% Model Generator of Spatio-Temporal Model
% blah blah blah
function model = ModelGenerator(N, C,L, sp, max_mu,max_eta,max_a,max_beta,stationary)

model = struct;
model.nodes =  N;
model.categories = C;%number of categories
model.locations=L;% number of locations for each category.note that L is a (C*1) array.

model.mu = (rand(N, C))*max_mu;
model.eta = ((rand(N, C) * max_eta));


model.a = sparse(N, N);
model.beta_of_users=rand(N,1)*max_beta;

model.outnetwork = cell(N,1);
model.innetwork = cell(N,1);

M = floor(sp * N^2); % number of total edges of network


if(M<N)
    disp('warning:sparsity level is less than N.')
end
edges = rand(M,3);
edges(:,1:2) = ceil(N*edges(:,1:2));

for m = 1 : M
    if(edges(m, 1)~=edges(m, 2)) %% avoid self edge
    model.a(edges(m, 1), edges(m, 2)) =( max_a * edges(m, 3));
    end
end

model.a(logical(eye(size(model.a))))=rand(1,N)*max_a; %% self edges


% connectivity structure
model.edges = 0;
for n=1:N
    model.outnetwork{n} = find(model.a(:,n) ~= 0);%% neigbors!
    model.edges = model.edges + length(model.outnetwork{n});
    model.innetwork{n} = find(model.a(n,:) ~= 0)';
end


% forcing the process to be stationary
if stationary
    egs = eigs(model.a);
    if abs(egs(1)) > 1
        model.a = model.a * rand() / abs(egs(1));
    end
end

%making parameters normal
for i=1:model.nodes
   normal_factor=sum(model.a(:,i))+sum(model.eta(i,:));
   model.a(:,i)=model.a(:,i)/normal_factor;
   model.eta(i,:)=model.eta(i,:)/normal_factor;
end
  

end




