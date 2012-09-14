function test_suite = test_basic_functools
    initTestSuite;
end


function test_system
    % Test a few components at once.

    join = @(sep, args) ...
        functools.if_(ischar(sep), @() ... % Input check
            functools.reduce(@(x, y) [x sep y], ... % Reduce to string
                functools.map(@num2str, args))); % Convert args to string.

    assertEqual(join({'Not a string'}, {1, 2, 3, 4}), []);
    assertEqual(join(', ', {1, 2, 3, 4}), '1, 2, 3, 4');
    assertEqual(join(', ', [1, 2, 3, 4]), '1, 2, 3, 4');
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
    assertEqual(functools.if_(true, @() 'Hello'), 'Hello');
    assertEqual(functools.if_(false, @() 'Hello'), []);
    assertEqual(functools.if_(false, @() 'Hello', @() 'Goodbye'), 'Goodbye');
    assertEqual(functools.if_(true, @(msg) msg, @(msg) msg, {'Hello'}), 'Hello');
    assertEqual(functools.if_(false, @(msg) msg, @(msg) msg, {'Goodbye'}), 'Goodbye');
    assertEqual(functools.if_(false, @(msg) msg, {'Hello'}, @(msg) msg, {'Goodbye'}), 'Goodbye');

    % Multiple arguments
    res = functools.if_(true, ...
        @(n, m) ones(n, m), {4, 4}, ...
        @(n, m) fprintf('Could not make ones with dims %d, %d', n, m), {4, 4});

    assertEqual(size(res), [4 4]);
end

function test_Y
    fact = functools.Y(...
        @(self)...
            @(n) ...
                functools.if_(n <= 1,...
                    @() 1,...
                    @() n * self(n-1)));
    assertEqual(fact(4), 24);
    assertEqual(fact(6), 1*2*3*4*5*6);

    fib = functools.Y(...
        @(self)...
            @(n) ...
                functools.if_(n <= 1,...
                    @() 1, ...
                    @() self(n - 1) + self(n - 2)));

    assertEqual(functools.map(fib, 0:9), {1 1 2 3 5 8 13 21 34 55})
end

function test_quicksort

    tail = @(lst) lst(2:end);
    head = @(lst) lst(1);

    qs = functools.Y(...
        @(self) ...
            @(lst) ...
                functools.if_(isempty(lst), ...
                    @() [], ... Is empty
                    @() [ ...
                        self(tail(lst(lst <= head(lst)))), ...
                        head(lst), ...
                        self(lst(lst > head(lst)))]));

    assertEqual(qs([8,2,45,0,4,1,2,3]), [0, 1, 2, 2, 3, 4, 8, 45]);

    biglist = randn(1, 1000);
    tic
    x1 = qs(biglist);
    fprintf('\nAnonymous Quicksort: '); toc

    tic
    x2 = qs_iter(biglist);
    fprintf('Subfunction Quicksort: '); toc

    tic
    x3 = sort(biglist);
    fprintf('Built-in sort: '); toc

    assertEqual(x1, x2);
    assertEqual(x1, x3);


    %     quicksort = @(lst) ...
end

function retval = qs_iter(lst)
    if isempty(lst)
        retval = [];
        return
    end
    pivot = lst(1);
    rest = lst(2:end);
    retval = [qs_iter(rest(rest <= pivot)) lst(1) qs_iter(rest(rest > pivot))];
end

function test_nth
    functools.nth(0, @disp, 'This test passes.');
    assertEqual(functools.nth(1, @() 4875), 4875);
    A = [1 2 2; 4 5 6; 7 8 9];
    [arg1, arg2] = find(mod(A, 2) == 0);
    assertFalse(all(functools.apply(@find, {mod(A, 2) == 0}) == arg1));
    assertFalse(all(functools.apply(@find, {mod(A, 2) == 0}) == arg2));

    assertEqual(functools.nth(2, @find, mod(A, 2) == 0), arg2);
end

