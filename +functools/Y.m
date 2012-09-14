% Make a recursive function out of a non-recursive one.
%
% The Y combinator is a function that accepts a function wrapping another
% function, and returns a function that can apply the outer function from
% within the inner one, or something.
%
% In real language: pass Y a function, wrapped in @(self), that uses calls
% to self as recursive calls, and you have a recursive function.
%
% Examples:
%
% >> fact = functools.Y(@(self) @(n) ...
%              functools.if(n <= 1, @() 1, @() n * self(n-1));
% >> fact(4)
% 24
function res = Y(f)
    import functools.apply;
    res = apply(...
        @(x) f(@(y) apply(apply(x, {x}), {y})), ...
        {@(x) f(@(y) apply(apply(x, {x}), {y}))});
end
