function parsave(varargin)
%PARSAVE Summary of this function goes here
%   Detailed explanation goes here

    len=length(varargin);
    save(varargin{1})
    for i=2:1:len
       eval([varargin{i}{1} '=' mat2str(varargin{i}{2}) ]); 
           save(varargin{1},varargin{i}{1}, '-append');
    end

end

