% Apply a function to a numeric or cell array of arguments
%
% val = functools.apply(fn, args)
%
% Accept a numeric or cell array of args, and
% return the result of applying fn to args as if
% each arg had been passed in separately.
%
% Example:
%
% >>> adder = @(x, y) x + z
% >>> sum = functools.partial(@functools.reduce, adder)
% >>> sumargs = @(varargin) sum(varargin)
% >>> sumargs(1, 2, 3, 4)
% 10
% >>> functools.apply(sumargs, [1, 2, 3, 4])
% 10
function retval = apply(fn, args)

    if isnumeric(args)
        args = num2cell(args);
    end

    retval = fn(args{:});

end
