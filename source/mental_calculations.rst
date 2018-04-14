========================================
Mental calculations for IT professionals
========================================

Let's talk about mental calculations!
=====================================

*Uhh... I'm not too interested in that stuff, I have a computer for that.*

Well, you wouldn't be wrong to think that. But your head is a tool that rusts
easily. I think we tend to rely too much on computers, especially in our work
where they're ubiquitous. The ability to compute without having to think of
it also means that we tend to trust those numbers without thinking twice
about it. On the contrary, when not having a keyboard in the hands we tend to
avoid computing at all.

I'm often asked in my job to estimate costs, durations, numbers... I like
being able to answer my clients without relying on my computer be it only
because I often don't have any by hand during meetings. Besides, it's not
nearly as hard as it seems using a few tricks and methods.

We're not talking about precise results here. When dealing with real numbers
we rarely need more than a few digits of precision. What we're talking about
is efficient yet educated estimates that lands within 10% of the actual
result. That's enough to take a decision or identify a risk. It's all in the
spirit of `Fermi estimates <http://lesswrong.com/lw/h5e/fermi_estimates/>`_.

So, what about looking at a concrete case to see some of those?

.. image:: ../image/math_kawaii.png
    :width: 50%

Bruteforcing a key
==================

*“How long would it take to bruteforce a 128-bits key?”*

A classical issue that comes up quite often. We'll first estimate the number
of keys that represent, then consider how fast we can test keys and finally
get an answer.


First trick: powers of two.
---------------------------

A 128-bits key means that the key is composed of 128 bits that each can take
two values. There are therefore 2¹²⁸ possibilities.

That's an exact number but that's not easy to deal with. Let's convert it to
a power of 10 instead.

.. admonition:: Tip

    To convert a power of two to a power of ten, just divide it by ten and
    multiply by three. The integer part is the power of ten.

So in our case, that means:

.. math::

    2^128\ \rightarrow\ 128\ \rightarrow\ 128/10 = 12.8\ \rightarrow\ 12.8×3 = 38.4\ \rightarrow\ 38

So 2¹²⁸ ≃ 10³⁸. That's way better for us because about everything is
expressed on a base 10 so a power of ten is easier to manipulate and compare
than a power of two. That's also why we'll use scientific notation whenever
possible.

Scientific notation of numbers is about separating their precise value
from their order of magnitude to make them easy to compare and manipulate.
To do that write the number as a number between 0 and 10, then multiply
by the corresponding power of ten.

For example 127348234 would be written 1.27348234×10⁸ in scientific
notation.

That notation looks more complicated, but when dealing with mental estimates
it's a bliss. Most of the time we only care about the order of magnitude of
the result, so converting all numbers into powers of ten is a good thing.

Note that we dropped 0.4 in the process of computing the power of ten. This
holds the "value" part of the scientific notation of the result and amounts
to about 2.5 once converted back from a power of ten. There is absolutely no
need to know that, but it's good to keep in mind that we rounded the result
down.

The hypothetical computer
-------------------------

So how fast can we test 10³⁸ keys? That depends on the hardware, which
evolves quite a lot... Are we using GPU? Are we using the cloud?

We're estimating, so we need an answer. The question of the power of
computation comes out often enough that having some kind of a baseline that's
a compromise between everything that is currently possible. I call that
machine HC-200 for “Hypothetical Computer 200-looks-so-cool".

What are its specs?

::

    HC-200 is a one-core 1GHz computer that can compute anything in one
    operation and requires at least one atom to be produced.

*Uhh... That sounds stupid.*

.. image:: ../image/consider_the_following_kirino.png
    :width: 50%

1GHz might not seem very high by today's standards, but it's on the same
order of magnitude as most personal computers and an easy number to
manipulate. Besides, this computer actually packs way more computing power
than those computers: it's able to test a key in only one operation while
that normally requires hundreds if not thousands of CPU cycles even with
multiple cores.

It has only one core but we're only using it as a mental baseline, it's easy
to imagine many of them working in parallel: just an additional division.

We'll maybe see in another post why we want the atomic restriction.

Back in track
-------------

So, 1GHz means a billion (10⁹) operations a second. How many seconds do we
need then?

.. math::

    10^38 / 10^9 = 10^{38-9} = 10^29

Whoa. I have no idea how much that represents. Let's express this in years
instead.

.. admonition:: Tip

    There are about π×10⁷ seconds in a year (π=3.14).

That's good to know! We can now write:

.. math::

    10^38 / 3.14 \cdot 10^7 = 1/3 \cdot 10^{38-7} = 10^31

*Wait, you did a mistake, 1/3 is 0.33 so shouldn't it be 3×10³⁰ ?*

Remember when earlier we rounded down? Now we round up to make for it. That's
alright.

.. admonition:: Tip

    Round up and down alternatively at will, it'll generally come out all
    right.

So we need 10³¹ years with one HC-200 to crack the key. Well, we have 50%
chances it's in the first half, but that still amounts to 5×10³⁰ years, or
one thousand billion billion billion years.

*But that was with one HC-200, what if we put a billion in parallel?*

We'd still need (`more than <https://en.wikipedia.org/wiki/Amdahl's_law>`_)
5×10³⁰ / 10⁹ = 5×10²¹ years, which is enough time to see through any Windows
update in sequence (in case you want a feel of eternity).

Conclusion
==========

We saw through a concrete case that few things are really necessary to get a
reasonable answer out. There were some multiplications to convert a power of
two into a power of ten, but that aside all we did was choosing the right
numbers, choosing when to round and addition/subtractions of powers.

For the skeptics, here is the answer provided with a computer with numbers as
precise as they can be using one HC-200.

.. code:: python

    >>> import math
    >>> number_of_possibilities = 2**128
    >>> number_of_possibilities
    340282366920938463463374607431768211456
    >>> power_of_ten = int(math.log(number_of_possibilities, 10))
    >>> power_of_ten
    38
    >>> seconds_in_year = 3600 * 24 * 365.25    # leap years too!
    >>> seconds_in_year
    31557600.0
    >>> number_of_possibilities / seconds_in_year
    1.0782897524556317e+31

So, we are 8% bellow the actual answer, well within our 10% margin. Not so
bad huh? It's not an isolated, made-up case, any similar situation would give
similar results.

What does that mean? It means you don't need a computer to provide numerical
answers. It means you're not slave to the machine. It's means `humanity's
still got a chance
<https://themathlab.com/writings/short%20stories/feeling.htm>`_
<*insert dramatic music here fading off in the horizon here*>.

There are many more tips and tricks that I'd like to talk about so I think
I'll do more of those!

Images source
-------------

- https://rmblee.deviantart.com/art/MATH-IS-SO-KAWAII-DESUUUUUUU-400216158

- https://warosu.org/sci/thread/9289137
