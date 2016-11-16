function output = count_min(inp )
output=zeros(size(inp,2),1);
for i=1:1:size(inp,1)
val=min(inp(i,:));
inds=find(inp(i,:)==val);
output(inds)=output(inds)+1;
end

end

