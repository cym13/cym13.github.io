==============================
Shell streams and redirections
==============================

Piping
======

This should be well-known already, it allows sending the output of a program
to the input of another.

.. code:: bash

    $ ls
    abc
    bcd
    cde

    $ ls | grep b
    abc
    bcd

Write to file
=============

One can write to a file using '>'.
In that case the content is dropped beforehand:

.. code:: bash

    $ ls > myfile.txt

    $ cat myfile.txt
    abc
    bcd
    cde

    $ echo "Cat attack!" > myfile.txt

    $ cat myfile.txt
    Cat attack!

Want to still get an output while writing to a file? Use tee!

.. code:: bash

    $ ls | tee myfile.txt
    abc
    bcd
    cde
    myfile.txt

    $ cat myfile.txt
    abc
    bcd
    cde
    myfile.txt

One can also append to a file using '>>':

.. code:: bash

    $ echo "Return of the evil cat!" >> myfile.txt

    $ cat myfile.txt
    abc
    bcd
    cde
    myfile.txt
    Return of the evil cat!

Of course, tee also works for appending with -a or --append:

.. code:: bash

    $ echo "Cats everywhere!" | tee -a myfile.txt
    Cats everywhere!

    $ cat myfile.txt
    abc
    bcd
    cde
    myfile.txt
    Return of the evil cat!
    Cats everywhere!

Read from file
==============

One can read from a file using '<', the content of the file is written to the
program's standard input.

.. code:: bash

    $ grep a <myfile.txt
    abc
    Return of the evil cat!
    Cats everywhere!

Ok, here it is not very useful... But there are cute and useful patterns
using it:

.. code:: bash

    $ while read line ; do
    .    echo "Ninja cat $line"
    . done < myfile.txt
    Ninja cat abc
    Ninja cat bcd
    Ninja cat cde
    Ninja cat myfile.txt
    Ninja cat Return of the evil cat!
    Ninja cat Cats everywhere!

Note also that '<' like other redirection symbol can be used anywhere on the
line (shell-dependant, but true for most):

.. code:: bash

    $ <myfile.txt while read line ; do
    .    echo "Ninja kitty $line"
    . done
    Ninja kitty abc
    Ninja kitty bcd
    Ninja kitty cde
    Ninja kitty myfile.txt
    Ninja kitty Return of the evil cat!
    Ninja kitty Cats everywhere!

Read from standard input
========================

You want to write multiple lines to a program's standard input without pain ?
Use '<<':

.. code:: bash

    $ grep kitten <<EOF
    . A kitten
    . Another kitten
    . Another kitten
    . It keeps going
    . EOF
    A kitten
    Another kitten
    Another kitten

Here, EOF is the terminator, the shell keeps reading until it sees it, then
it sends all output to the program. Still not really useful as it is, but it
can come in handy sometimes, like when needing to write a small file (real
programmers use cat by the way):

.. code:: bash

    $ cat >truth.sh <<EOF
    . #!/bin/sh
    . while [ 42 ] ; do
    .     echo "KITTENS!!!"
    .     echo "KITTENS EVERYWHERE!!!"
    . done
    . EOF

    $ cat truth.sh
    #!/bin/sh
    while [ 42 ] ; do
        echo "KITTENS!!!"
        echo "KITTENS EVERYWHERE!!!"
    done

Read from a text (Ugh… wut?)
============================

Sometimes, we just want to pass a single line, a variable for example. Let's
do that with '<<<':

.. code:: bash

    $ cat <<<"I'm a hipster, echo is so mainstream!"
    I'm a hipster, echo is so mainstream!

Ok... But what if my data isn't suitable for stdin?
===================================================

It happens sometimes, you have a nice data set that just isn't formated the
right way. In such situations, xargs often comes in handy.

.. code:: bash

    $ ls | grep a
    abc
    bcd
    cde

We want to do "ls -l" on each of these files to get more information...
The naive solution would be:

.. code:: bash

    # Novice: "Hey! I know that trick!"
    $ ls | grep a | while read line ; do ls -l "$line" ; done
    ...

But the best would be to do:

.. code:: bash

    # Master: "Don't solve the problem, find another one"
    $ ls | grep a | xargs ls -l
    ...


How does it work? What xargs does is that it takes each line and calls its
arguments with those lines as arguments. The two following expressions are
indeed equivalent:

.. code:: bash

    $ xargs ls -l <<EOF
    . abc
    . bcd
    . cde
    . EOF
    ...

    $ ls -l abc bcd cde
    ...
