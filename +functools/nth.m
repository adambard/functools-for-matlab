% Grab the nth output argument from fn
%
%   functools.nth(n, fn, [varargs_for_fn])
%
% Calls fn with the extra arguments provided, and returns the nth output
% from it.
%
% Secret usage: n can be 0, enabling you to wrap functions with no output
% without an error.
function val = nth(n, fn, varargin)
    switch n
        case 0
            fn(varargin{:});
            val = [];
        case 1
            [val] = fn(varargin{:});
        case 2
            [~, val] = fn(varargin{:});
        case 3
            [~, ~, val] = fn(varargin{:});
        case 4
            [~, ~, ~, val] = fn(varargin{:});
        case 5
            [~, ~, ~, ~, val] = fn(varargin{:});
        case 6
            [~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 7
            [~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 8
            [~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 9
            [~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 10
            [~, ~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 11
            [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 12
            [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 13
            [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        case 14
            [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, val] = fn(varargin{:});
        otherwise
            error('nth:TOO_MANY', ...
                ['functools.nth can only get arguments up to 14. If you'...
                ' need more, feel free to add them']);
    end
end

