Matlab Utils
#################

This is a github repo where I'm going to keep non-company specific MATLAB
tools that I whip up.

functools
===========

The functools package is a collection of utility functions for
working in MATLAB in a more functional style.

Testing requires matlab-xunit.

Examples
------------

Each function is documented individually. The contents of the test file should
be enough to give you an idea of how things work::

    function test_system
        % Test a few components at once.

        join = @(sep, args) ...
            functools.if(ischar(sep), @() ... % Input check
                functools.reduce(@(x, y) [x sep y], ... % Reduce to string
                    functools.map(@num2str, args))); % Convert args to string.

        assertEqual(join({'Not a string'}, {1, 2, 3, 4}), []);
        assertEqual(join(', ', {1, 2, 3, 4}), '1, 2, 3, 4');
        assertEqual(join('+', {'A', 2, 'x'}), 'A+2+x');

        % This is a profoundly stupid way of doing things, but it's good for
        % demonstration.
        ghettosum = functools.compose(...
            functools.partial(join, '+'), @eval);

        assertEqual(ghettosum({1, 2, 3, 4, 5, 6}), 21);
        % => eval(join('+', {1, 2, 3, 4, 5, 6}))
    end

    function test_reduce
        assertEqual(10, functools.reduce(@(x, y) x + y, [1, 2, 3, 4]))
        assertEqual(11, functools.reduce(@(x, y) x + y, [1, 2, 3, 4], 1))
    end

    function test_compose
        nth_even = functools.compose(@(x) x - 1, @(x) x * 2);
        assertEqual(nth_even(1), 0);
        assertEqual(nth_even(2), 2);
        assertEqual(nth_even(3), 4);
    end

    function test_apply
        adder = @(x, y) x + y;
        sum = functools.partial(@functools.reduce, adder);
        sumargs = @(varargin) sum(varargin);

        assertEqual(sumargs(1, 2, 3, 4), 10);
        assertEqual(functools.apply(sumargs, [1, 2, 3, 4]), 10);
    end

    function test_partial
        a = 1;
        b = ones(2, 1) / 2;
        movingavg2 = functools.partial(@filter, b, a);
        assertElementsAlmostEqual(movingavg2(1:4), [0.5, 1.5, 2.5, 3.5], 'absolute', 6);

        movingavg2 = functools.partial(@filter, b);
        assertElementsAlmostEqual(movingavg2(a, 1:4), [0.5, 1.5, 2.5, 3.5], 'absolute', 6);

    end

    function test_rpartial_more
        map = functools.rpartial(@cellfun, 'UniformOutput', false);
        assertEqual(map(@(x) x + 2, {-1, 0, 1, 2}), {1 2 3 4});
    end

    function test_rpartial
        isodate = functools.rpartial(@datestr, 'yyyy-mm-dd HH:MM:SS');
        assertEqual(isodate(datenum(2010, 1, 1)), '2010-01-01 00:00:00');
    end

    function test_map
        res = functools.map(@(x) x * 2, {1, 2, 3});
        assertEqual(cell2mat(res), [2, 4, 6]);
        functools.map(@fprintf, {'functools.map ', 'is ', 'working'});
    end

    function test_if
        assertEqual(functools.if(true, @() 'Hello'), 'Hello');
        assertEqual(functools.if(false, @() 'Hello'), []);
        assertEqual(functools.if(false, @() 'Hello', @() 'Goodbye'), 'Goodbye');
        assertEqual(functools.if(true, @(msg) msg, @(msg) msg, {'Hello'}), 'Hello');
        assertEqual(functools.if(false, @(msg) msg, @(msg) msg, {'Goodbye'}), 'Goodbye');
        assertEqual(functools.if(false, @(msg) msg, {'Hello'}, @(msg) msg, {'Goodbye'}), 'Goodbye');

        res = functools.if(true, ...
            @(n, m) ones(n, m), {4, 4}, ...
            @(n, m) fprintf('Could not make ones with dims %d, %d', n, m), {4, 4});

        assertEqual(size(res), [4 4]);
    end

