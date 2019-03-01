============================================
How to size a hash? More mental calculations
============================================

The issue
=========

Let's say that we have an expected number of users to whom we would like to
give a unique unpredictable identifier. Most programmers will think of a hash
function, but which one? How to size the hash we'd like to use to ensure that
no collision will occur?

That's what we're answering today, and in the fashion of the `previous
episode <mental_calculations.html>`_ we're doing it without any calculator.

We won't delve into the security aspect of hashes here but if you're
manipulating secrets you really want to use a safe cryptographic hash and not
something like crc32 or sha1.

First approach
==============

A fundamental property of hashes is that they have a fixed size and so a
fixed number of possible values. A 32 bit hash will have a maximum of 2³²
values.

So we're just trying to find the right power of 2 to accomodate our number of
users. Let's say we have a billion of those.

We might remember the trick: to convert a power of 2 into a power of 10
divide by 10 and multiply by 3.

Conversely we can write:

.. math::

   10^9 \rightarrow 9÷3×10=30 \rightarrow 2^30

So a 30 bit hash would accomodate a billion users. And to get some margin we
can opt for a 32 bit hash like CRC32.

Problem solved, right?

.. image:: ../image/steinsgate_mayuri.png
   :width: 40%

The birthday paradox issue
==========================

If you try you'll soon encounter lots of collisions. That's because of the
`birthday paradox <https://en.wikipedia.org/wiki/Birthday_problem>`_.

That paradox roughly says that while finding an element that has the same
hash as a specific element is very hard, finding any two elements that have
the same hash is much easier.

That's why to have more than 50% chance of finding someone that has the same
birthday as you you need to gather 183 people, but to have 50% of having
*any two people* in the group that share their birthdays you only need to
gather 23 people.

A good rule of thumb is that if you have *n* possibilities from which you
choose at random you'll have 50% chance of having a collision in a group of
about *√n* samples.

Final method
============

So how does that help us for our hashing issue?

Well, it means that we need a set of possibilities bigger by a square
factor. That is, we just need to multiply the power by 2.

.. admonition:: Tip

   To know when the first collision has more than a 50% chance of happening
   divide the power by 2.

Hence for a billion users we write:

.. math::

   10^9 \rightarrow 9÷3×10=30 \rightarrow 30*2=60 \rightarrow 2^60

With a 60 bit hash we should therefore be good with respect to collisions.

.. image:: ../image/steinsgate_ok.png
   :width: 40%

Conclusion
==========

This is useful to size hashes and avoid disruption of service of course.
However it's also worth noting that many protocols rely on the lack of
colisions for security. For example a collision may mean that you can inject
a packet in a communication. In that case, it is worthwhile to be able to
quickly judge the number of packets you'll need to gather to exploit that
fact.

Images source
-------------

- Unknown

