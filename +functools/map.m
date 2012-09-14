% Apply a function to each member of a cell (or numeric) array.
% 
% val = functools.map(fn, args)
%
% Accept a numeric or cell array of args, and
% return the result of applying fn to each of args.
%
% Always returns a cell array, so be sure to recast it.
%
% Example:
%
% >>> dbl = @(x) x * 2
% >>> functools.map(dbl, [1, 2, 3])
% [2, 4, 6]
% >>> functools.map(@(x) fprintf('%s\n', x), {"This" "Is" "Sparta"})
% "This"
% "Is"
% "Sparta"
function retval = map(fn, args)
    was_numeric = isnumeric(args);
    if was_numeric
        args = num2cell(args);
    end

    retval = cellfun(fn, args, 'UniformOutput', false);

end
