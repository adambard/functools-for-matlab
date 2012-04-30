% Partially apply the arguments provided, from the right
%
% See functools.partial; this is just like it, but applies partial args
% from left to right.

function fn = rpartial(fn_, varargin)
    args = varargin;
    fn = @(varargin) fn_(varargin{:}, args{:});
end
