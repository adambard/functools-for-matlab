functools package for MATLAB
============================

Did you know that MATLAB has built-in support for closures? Develop for MATLAB in a functional style with functools.

HUGE DISCLAIMER
===============

MATLAB is incredibly slow at applying anonymous functions. Don't use this library for performance,
use it for convenience. I tend to use it for string manipulations mostly.

Tools Included
==============
Specifically, the following tools are implemented:

**Basic functional programming operations:**

* `compose` - Compose a function out of two or more other functions
* `apply` - Apply a function to a cell array of arguments, as if the elements of the array were individual args
* `partial` - Partially apply a function
* `rpartial` - Right-handed partial

**Collection operations**

* `map` - Apply a function to each member of a vector/cell array and return a modified collection of the same type
* `reduce` - Reduce (fold) a cell array or vector of values into a single one using repeated function application

**Utilities**

* `if_` - Functional branching, wrapping branches in functions to defer execution
* `nth` - Return the nth output argument from calling a function.
* `Y` - The Y combinator. Yes!

All the following examples assume you've done

    import functools.*


Examples
======================

Most of these examples are taken from the tests. Sorry if they're a bit contrived.

Compose
-------

```matlab
    nth_even = compose(@(x) x - 1, @(x) x * 2)
    nth_even(1) % => 0
    nth_even(2) % => 2
    nth_even(3) % => 4
```

Apply
----

```matlab
    adder = @(x, y) x + y;
    tot = partial(@reduce, adder);
    sumargs = @(varargin) sum(varargin);

    sumargs(1, 2, 3, 4) % => 10
    apply(sumargs, [1, 2, 3, 4]) % => 10
```

Partial & rpartial
------------------

These two are probably the most capable of making MATLAB code easier to read and less painful to write.

```matlab
    % partial
    a = 1;
    b = ones(2, 1) / 2;
    movingavg2 = functools.partial(@filter, b, a);
    movingavg2(1:4) % => [0.5, 1.5, 2.5, 3.5]
```

```matlab
    % rpartial
    isodate = rpartial(@datestr, 'yyyy-mm-dd HH:MM:SS');
    isodate(datenum(2010, 1, 1)) % => '2010-01-01 00:00:00'
```

Rpartial is notable for having a particularly useful function in MATLAB: pre-applying those key/value parameters that almost every
base matlab function has:

```matlab
    % Annoying
    cellfun(@(x) x + 2, {-1, 0, 1, 2}, 'UniformOutput', false) % => {1, 2, 3, 4}
```

```matlab
    % Awesome
    map_ = rpartial(@cellfun, 'UniformOutput', false)
    map_(@(x) x + 2, {-1, 0, 1, 2}) % => {1, 2, 3, 4}
```

Map
---

```matlab
    % Unfortunately, function application in MATLAB is even slower than its slow for loops.
    % So, you probably shouldn't use this for math, although you can.
    map(@(x) x * 2, {1, 2, 3}) % => {2, 4, 6}
```


```matlab
    % Better to use this as a utility function
    pwd % => /some/directory
    filepaths = map(partial(@fullfile, pwd), {'1.txt', '2.txt', '3.txt', '4.txt'});
    filepaths{2} % => '/some/directory/2.txt'
```

Reduce
------

```matlab
    reduce(@(x, y) x + y, [1 2 3 4]) % => 10
    reduce(@(x, y) x + y, [1 2 3 4], 10) % => 20
```

```matlab
    % Something cleverer
    join = @(sep, args) ...
        reduce(@(x, y) [x sep y], ...
            map(@num2str, args));
    join(', ', [1 2 3 4]) % => '1, 2, 3, 4')
```


`if_`
-----

I'dve called it `if` but for the obvious naming conflict. Always call it with functions!

```matlab
    functools.if_(true, @() 'Hello') % => 'Hello'
    functools.if_(false, @() 'Hello') % => []
    functools.if_(false, @() 'Hello', @() 'Goodbye') % => 'Goodbye'
    functools.if_(true, @(msg) msg, @(msg) msg, {'Hello'}) % => 'Hello'
    functools.if_(false, @(msg) msg, @(msg) msg, {'Goodbye'}) % => 'Goodbye'
    functools.if_(false, @(msg) msg, {'Hello'}, @(msg) msg, {'Goodbye'}) % => 'Goodbye'
```

nth
---

```matlab
    % Wrap functions that refuse to return a value with partial(nth, 0)
    apply(@disp, {'Disp will choke on this'}) % => ERROR
    apply(partial(@nth, 0, @disp), {'Disp will actually display this'}) % => [] (But the text is displayed)
```

```matlab
    % 2nd output of sort is the former indices of the newly-sorted elements
    nth(1, @sort, [100, 400, 200, 300]) % => [100 200 300 400]
    nth(2, @sort, [100, 400, 200, 300]) % => [1   3   4   2]
```

Y
-

The Y combinator is a way of making recursive functions in languages which lack
recursion but which have first-class functions, which is true of almost no
language in use today.

But, the meta-language of anonymous functional MATLAB fits this bill perfectly!

Y takes a function that takes one argument, self, which returns an inner function.
In that inner function, you can use self as an application of that inner function!

This is all better explained by example:

```matlab
    fact = Y( ...
        @(self) ... % Accepts a function...
            @(n) ... % that returns a function ...
                if_(n <= 1, ...
                    @() 1, ...
                    @() n * self(n-1))); % ... that uses self recursively.
    fact(4) % => 24
    fact(6) % => 720
```

```matlab
    fib = functools.Y(...
        @(self)...
            @(n) ...
                if_(n <= 1,...
                    @() 1, ...
                    @() self(n - 1) + self(n - 2)));

    functools.map(fib, 0:9) % => {1 1 2 3 5 8 13 21 34 55}
```




```matlab
    tail = @(lst) lst(2:end);
    head = @(lst) lst(1);
    qs = Y(...
        @(self) ...
            @(lst) ...
                if_(isempty(lst), ...
                    @() [], ... Is empty
                    @() [ ...
                        self(tail(lst(lst <= head(lst)))), ...
                        head(lst), ...
                        self(lst(lst > head(lst)))]));

    quicksort([8,2,45,0,4,1,2,3]) % => [0, 1, 2, 2, 3, 4, 8, 45]
```

Note that this quicksort is anything but quick.

```matlab
    biglist = randn(1, 1000);
    tic
    x1 = qs(biglist);
    fprintf('\nAnonymous Quicksort: '); toc
    % => Anonymous Quicksort: Elapsed time is 0.929396 seconds.

    tic
    x2 = sort(biglist);
    fprintf('Built-in sort: '); toc
    % => Built-in sort: Elapsed time is 0.000062 seconds.
```


I wouldn't use `Y` in production, it's mostly for show.

License
=======

Released under the MIT License

© 2012 Adam Bard

