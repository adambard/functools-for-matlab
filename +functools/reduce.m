% Combine a list (cell array) of vars using the function passed. 
%
% retval = reduce(fn, vals, varargin)
%
% Reduce (fold) a cell vector of vals (numeric vectors will be converted) by calling
% fn, a function of two variables, recursively.
%
% If an optional third argument is provided, use it as an input to the first
% iteration.
%
% Example:
%
% >>> total = functools.reduce(@(x, y) x + y, [1, 2, 3, 4])
% 10
% >>> total = functools.reduce(@(x, y) x + y, [1, 2, 3, 4], 1)
% 11

function retval = reduce(fn, vals, varargin)
    if ~iscell(vals)
        vals = num2cell(vals);
    end

    if nargin > 2
        retval = varargin{1};
        start = 1;
    elseif isempty(vals)
        retval = [];
        return;
    elseif length(vals) <= 1
        retval = vals{1};
        return;
    else
        retval = fn(vals{1}, vals{2});
        start = 3;
    end

    for ii=start:length(vals)
        retval = fn(retval, vals{ii});
    end
end

