====================
D sightseeing: crc32
====================

Sightseeing?
============

Yeah... I like D but there is just so much to tell about it that it's hard to
convey my enthusiasm to my friends. So instead of a 3 day conference let's
analyse a very simple script that serves an actual purpose: a replacement for
the perl utility **crc32** that computes the famous hash value of files or
the standard input.

The original script is 89 lines long with spaces and comments. You can find
it `here <../file/crc32.d>`_.

Because I wanted to keep indentation throughout the snippets despite the best
efforts of my html generator, you will sometimes find three dots at the very
beginning of a line. You may safely ignore them.

Let's see the beast!

.. image:: ../image/girl_glancing.png
    :width: 40%

Prelude to the program
======================

D accepts shebangs, rdmd is a program that's used to launch programs
"script-style" by compiling on the fly (and avoiding recompiling if
possible). It can also be used to run little command lines as D doesn't have
a repl. Very handy.

::

    rdmd --eval='[1, 2, 3].map!(x => x*2-1).writeln'

Below are some imports from the standard library.

.. code:: d

    #!/usr/bin/env rdmd

    import std.file;
    import std.stdio;
    import std.algorithm;

As in C there are types and there are storage classes. `enum` is a storage
class for compile-time constants.

.. code:: d

    enum vernum = "2.0.0";

Here we demonstrate a multi-line string. There are other ways but it's a good
example of the versatility of strings in D.

.. code:: d

    enum help = q"EOF
    Compute CRC32 checksum of streams and files

    Usage: crc32 [options] [FILE...]

    Arguments:
        FILE  The file to compute the checksum of
              If FILE is a directory all files within it will be taken
              If FILE is missing the standard input is taken

    Options:
        -h, --help      Print this help and exit
        -v, --version   Print version and exit
        -r, --recursive Traverse subdirectories recursively
    EOF";

Our first function
==================

As in python you can import things anywhere. Contrary to python it is
considered good practice to import as locally as possible. This is because
templates are common, and are compiled only if instanciated, so you don't
import (and compile) what you don't use that way.

.. code:: d

    /**
     * Computes the crc32 checksum of a file and returns it as a string
     */
    string crc32(File chunks) {
        import std.uni;
        import std.digest.crc;

Use of UFCS and optional parentheses as explained below. Read the file by
chunks, compute the crc32 which returns a byte array, and build a string from
that. I think it's pretty self-explanatory.

.. code:: d

        return chunks.byChunk(8192)
                     .crc32Of
                     .reverse
                     .toHexString
                     .toLower;
    }

A word on UFCS
--------------

I talked about UFCS but didn't explain what it was on the spot not to cut the
flow of the code too much. It is a very easy concept; it just states that the
first argument of a function can be moved before it using a dot.

The following calls are all perfectly equivalent (and useless):

.. code:: d

    writeln(toLower("TEST"), ".txt");
    toLower("TEST").writeln(".txt");
    "TEST".toLower().writeln(".txt");

To that we must add that empty parentheses are always optional, so we can
also write:

.. code:: d

    "TEST".toLower.writeln(".txt");

This serves two purposes.

First of all it looks nice: it gives a feeling of pipeline programming that
fits well processes such as our *crc32* function where the code flows from
one function into another.

Secondly it allows making weak overloads of methods. Let's say you have a lot
of classes and would like to add a method to manage a given type but don't
want to write an overload for each class. One way is to write a function
that manages that type and can take any of the classes we want and use UFCS
to make it look like a method call.

There are of course limits to that approach so it's not what I'd recommend in
that situation, but it can definitely come in handy sometimes.

The main
========

Note the arguments: simple.

I didn't have to return an int, I could have returned void. Had I done that,
the return value would have been 0 if no exception was thrown, 1 otherwise
(with a big stacktrace, but that's beyond the point.

Also we have selective imports like in python again. Note the last one: some
common parts of the standard C libraries are exposed directly through this
part of the D standard library. After all, D interacts very well with C, so
why not use its functions where useful?

.. code:: d

    int main(string[] args) {
        import std.getopt:       getopt;
        import std.array:        array;
        import core.stdc.stdlib: exit;


Type deduction. Works about everywhere except as function argument
(can be the function return value though). If the compiler knows the
type, why write it? Makes for simpler code, especially since sometimes
the type cannot be known (eg: type defined in a function then returned,
it's called a voldemort type and is sometimes used for encapsulation).

.. code:: d

    …   auto spanmode = SpanMode.shallow;

Managing arguments
------------------

Side note but I like getopt in D.

There are different ways to define lambda functions in D. One way is `(x =>
x*2;)`. This is equivalent to: `(auto x) { return x*2; }`. But what if the
function takes no argument? Then you get empty parentheses. And empty
parentheses are optional. So below, half the arguments are actually lambda
functions.  Those can be hard to spot at first admitedly, so prefer the other
forms.

.. code:: d

    …   getopt(args,
            "recursive|r", { spanmode = SpanMode.depth; },
            "version|v",   { writeln("crc32 v", vernum); exit(0); },
            "help|h",      { write(help); exit(0); },
        );

The langage has what's called "slices". It is what we call "a range" in
python: for example here `args[1..$]` is equivalent to the python `args[1:]`.
One interesting thing is that they do not copy data, it's simply a pointer's
game. They are therefore very interesting when making parsers etc.

.. code:: d

    …   // Without arguments, use stdin
        if (args[1..$].length == 0) {
            writeln(stdin.crc32);
            return 0;
        }

Templates
---------

Our first use of a template. isFile is a function that takes a file and
returns a boolean. Filter is a template (as are most things that we
manipulate here actually, but it's the first one that we will use as a
template). It takes as first compile-time argument a lambda or function and
as first runtime argument a range (D's concept of iteration, similar to
generators in Python).

Here the call could have been written:

.. code:: d

    filter!(isFile)(args[1..$])

The first set of parens is prefixed with ! so it's a compile-time argument.
The second set is the runtime argument. In C++ it would have been
`filter<isFile>(args[1..$])`.  Remember UFCS? We can rewrite it (dropping the
empty parens):

.. code:: d

    args[1..$].filter!(isFile)

And as the call is unambiguous we can drop the last parens as well.

Filter returns a range, it is lazy as many things in the standard library,
and as we want to reuse it we will turn it into an array which is the last
call of the section (equivalent to `list()` in python. This array is
GC-allocated, we could have filled a malloced-buffer though.

.. code:: d

    …   // Make list of inputs
        string[] fileList = args[1..$].filter!isFile.array;

Ok, now that the basics are understood, we do the same thing but bigger, and
with more functions!

We introduce map that also takes a function or lambda as compile-time
argument. Here we pass a lambda. The call is similar to python-ish
`map(lambda d: dirEntries(d, spanmode), ...)`.

each is another interesting template. It's just a foreach actually, it
doesn't bring anything, it exists solely because it fits well with UFCS. The
body of the foreach is passed as a lambda which uses more of what we saw.

There is a last subtlety though: the ~= operator. It's like += in python, but
D decided to separate addition (+) and concatenation (~).

.. code:: d

    …   // Add inputs from directory arguments
        args[1..$].filter!isDir
                  .map!(d => dirEntries(d, spanmode))
                  .each!((dir) => fileList ~= dir.map!(e => e.name)
                                                 .filter!isFile
                                                 .array);

Not much to say next...

.. code:: d

    …   // Remove duplicates
        sort(fileList);
        fileList = fileList.uniq.array;

A real foreach. We didn't specify the type of f so it's infered.

.. code:: d

    …   foreach (f ; fileList) {
            File file;


This is interesting. We don't have context managers like python.  However we
have scope managers. The following line ensures that when quitting the scope
defined by the enclosing {} we will close the file.

There are also scope(success) and scope(error), and they can be used multiple
times in a same scope: they just stack nicely at the end.

.. code:: d

    …       scope(exit) file.close;


Exceptions, very classic. One note though: D has two kinds of Throwables:
Exceptions and Errors. The former are meant to be caught, the later signal an
unrecoverable error. They are not to be caught. This distinction doesn't mean
much but shows well the fact that D is meant to build programs that work
*correctly*.

.. code:: d

    …       try {
                file = File(f, "rb");
            } catch(FileException ex) {
                stderr.write(ex.msg);
                continue;
            }

This first line is actually a function call, optionnal parens etc...
I like optional parentheses, maybe to the point of abuse. I don't know. It's
my style and not D's recommended style though, so if you don't like it just
write it differently.

.. code:: d

            auto crc = file.crc32;
            if (crc)
                writefln("%s\t%s", crc, f);
        }

        return 0;
    }

Conclusion
==========

Ok, so we saw many things in such a small program. Maybe too much. One thing
is certain though: I wrote this program a long time ago to fill a real need
and it was not meant as a demonstration example. It uses so many D features
because they are actually enjoyable and easy to use in real life even in such
short scripts.

There is much more to say so I hope I'll have the occasion to go sightseeing
with you again in the future.

Image source
------------

- Unknown
