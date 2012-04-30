% fn = compose(varargin)
%
% Returns a function that is a composition of the functions passed as arguments
% to compose.
%
% Regrettably, only works on functions with one input due to limitations of MATLAB.
%
% Example:
%
% >>> nth_even = compose(@(x) x - 1, @(x) x * 2)
% >>> nth_even(1) == 0
% >>> nth_even(2) == 2
% >>> nth_even(3) == 4
% ...
%
function fn = compose(varargin)
    fn = functools.reduce(@compose2, varargin);
end

function fn = compose2(fn1, fn2)
    fn = @(x) fn2(fn1(x));
end

