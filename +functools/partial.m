% fn = partial(fn, varargin)
%
% Return a function with one or more variables pre-applied.
%
% Example:
%
% Produce a function to do a moving average
%
% >>> a = 1
% >>> b = ones(2, 1) / 2
% >>> movingavg2 = functools.partial(@filter, b, a);
% >>> movingavg(1:4)
% [0.5, 1.5, 2.5, 3.5]
% (same as filter(b, a, 1:4))

function fn = partial(fn_, varargin)
    args = varargin;
    fn = @(varargin) fn_(args{:}, varargin{:});
end
