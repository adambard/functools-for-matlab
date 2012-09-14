% Functional IF branching. Evaluation is deferred by wrapping branches in functions.
%
% if(predicate, if_fn) Call if_fn with no args, only if <predicate>
% if(predicate, if_fn, args) Call if_fn with args {args}, passed as a cell array, only if <predicate>
% if(predicate, if_fn, else_fn) Call if_fn or else_fn depending on <predicate> in the obvious way.
% if(predicate, if_fn, else_fn, args) Call if_fn with {args} if <predicate>, else call else_fn with {args}
% if(predicate, if_fn, ifargs, else_fn, elseargs) call if_fn with {ifargs} if <predicate>, else call else_fn with elseargs
%
% Examples:
%
% >>> if(true, @() 'Hello')
% Hello
% >>> if(false, @() 'Hello')
% []
% >>> if(false, @() 'Hello', @() 'Goodbye')
% Goodbye
% >>> if(true, @(msg) msg, @(msg) msg, {"Hello"})
% Hello
% >>> if(false, @(msg) msg, @(msg) msg, {"Goodbye"})
% Goodbye
% >>> if(false, @(msg) msg, {"Hello"}, @(msg) msg, {"Goodbye"})
% Goodbye

% NOTE: Function will be called as "functools.if" thanks to filename, even though it
% has an underscore here. Run the tests if you don't believe me.
function retval = if_(predicate, if_fn, varargin)

    is_fn = @(arg) strcmp(class(arg), 'function_handle');

    if_args = [];
    else_fn = [];
    else_args = [];
    retval = [];

    % Sort arguments
    if nargin >= 5
        if_args = varargin{1};
        else_fn = varargin{2};
        else_args = varargin{3};
    elseif nargin == 4
        else_fn = varargin{1};
        if_args = varargin{2};
        else_args = varargin{2};
    elseif nargin == 3
        if is_fn(varargin{1})
            else_fn = varargin{1};
        else
            if_args = varargin{1};
        end
    end

    % Validate input
    if ~is_fn(if_fn)
        error('FUNCTOOLS:IF', 'Invalid if_fn (expected function, got %s)', class(if_fn));
    end
    if ~isempty(else_fn) && ~is_fn(else_fn)
        error('FUNCTOOLS:IF', 'Invalid else_fn (expected function, got %s)', class(else_fn));
    end
    if ~isempty(if_args) && ~iscell(if_args)
        error('FUNCTOOLS:IF', 'Invalid argument (expected cell, got %s)', class(if_args));
    end
    if ~isempty(else_args) && ~iscell(else_args)
        error('FUNCTOOLS:IF', 'Invalid argument (expected cell, got %s)', class(else_args));
    end

    % Call appropriate function
    if predicate
        retval = functools.apply(if_fn, if_args);
    elseif ~isempty(else_fn)
        retval = functools.apply(else_fn, else_args);
    end
end
