=============================
Dirduster: short presentation
=============================

tl;dr
=====

`Dirduster <https://github.com/cym13/dirduster>`_ is a fast, command-line web
directory bruteforcing tool written in D and used professionally for years
with much satisfaction.

What is dirduster?
==================

When assessing the security of a website it is important to map all entry
points. One common strategy for that is called “spidering”: start from the
home page and recursively follow all links.

This approach is not very interesting in my opinion and can even be
dangerous. It can only find pages that are meant to be available and for
websites that have thousands of similar pages it can be difficult to find the
ones that are different and actually present a different kind of interaction
(and different possible vulnerabilities).

There is another approach traditionally called “dirbusting” in reference to
the most popular tool for the job: dirbuster. Dirbusting consists in taking a
list of common file and directory names and testing them on a URL. It's very
effective to find forgotten or hidden administration interfaces, directories
to be explored, files to be read. Even when the file isn't available just
noticing a different error code can indicate what framework or tools are used
on the website.

Dirbusting is one of my main weapons to attack websites so I needed a good
tool. Therefore I created dirduster. It is a compiled, multithreaded program
able to perform fast dirbusting. It also has lots of configuration options
to adapt to any situation you may encounter. And if you're wondering about
the name, it's because it's similar to dirbuster but written in the `D
programming language <https://dlang.org/>`_.

Why not dirb, dirbuster, gobuster...?
=====================================

There are lots of reasons but the basic idea is that I didn't find a tool
that worked as well as I wanted it to.

.. figure:: ../image/rd_shrug.png
    :width: 40%

Dirbuster
---------

This is by far the most popular tool to do dirbusting and I really don't like
it.

It's graphical which means that I can't easily run it via SSH on a
captured server and leave it there in a screen session while I continue the
assessment elsewhere for example. There exists a command-line interface that
I never managed to get to work properly. Feature-wise it's rather complete
although not as much as dirduster ended up to be. For example it can only do
GET and HEAD requests and (more importantly) has no real way to filter
results.

Filtering is key. Some applications respond with non-standard error codes.
Some applications always return 200 no matter what. A good dirbusting tool
needs to be able to separate the wheat from the chaff. Dirbuster allows you
to customize what error codes should be ignored, to exclude pages matching a
given regex and its text interface is well suited to grep away any page
matching a given size for example.

Dirb
----

Dirb is another common tool since it is installed by default on Kali Linux.
It's not a bad tool: it's more customizable than dirbuster and rather easy to
grep. But it has its issues.

First of all it's slow. You cannot set the number of concurrent threads in
dirb, by default it creates as many as there are processors. Which is good
right? Wrong. Dirbusting is not a CPU-heavy task, most of the time is spent
waiting for an answer from the server. Each CPU could easily handle 100
threads that wait doing nothing, but with dirb if you have two CPUs you will
send two requests at a time, never more.

Another issue is that dirb isn't well designed. It doesn't follow any
development convention: -h and --help don't print any help, passing an option
before the URL doesn't work, it must be placed after (which is exactly the
opposite of any UNIX tool), etc. It's just clunky.

Also it only supports one URL at a time. Launching dirb many times is
possible of course, but it's nice to be able to test many URLs at once.

Other tools
-----------

I did it a few years ago and certainly didn't take the time to try them all.
If you find that some other tool works better for you, go for it (but give
dirduster a try first)!

How do you use it?
==================

First of all I must admit that even though dirduster comes with some
dictionaries (the dirbuster ones) I much prefer the raft lists from `SecLists
<https://github.com/danielmiessler/SecLists>`_. They are very effective for
me.

I generally start with a small list in --single-pass in order to get a feel
of the application: what are errors like? What codes, what page sizes etc.

If I get surprising results I make sure to match my browser's request by
setting the corresponding headers. I then proceed to filter the results by
return code, error strings and page size (in that order).

Adding return codes in particular is easy: with --list-ignore you get the
comma-separated list of all codes that are ignored by default by dirduster.
You can overwrite that list by using --ignore: just pass it a new list with
error codes that are relevant to your application.

Once my filters are in place I start using bigger lists. Hopefully by that
point I have a better idea of what to expect from the website so I can target
specific technologies.

In last resort I remove --single-pass to try finding directories recursively.
This doesn't work on many websites though so I often don't bother. Similarly
--directories (which tries each URL with and without a trailing forward
slash) is sometimes useful but often not worth investing any time.

Testing other methods can lead to very interesting results but it's a rather
new feature so I have yet to determine just how useful it is in practice.

And that's about it. Pipe to tee, maybe grepping to remove some duds and
you're good to go.

What next?
==========

Nothing. I will continue supporting dirduster of course, it's one of my main
tools at work and I use it weekly, but I feel like it has the features it
needs. I don't plan on adding more unless someone comes with a pull request
or a very well thought argument.

I hope it fits your toolbox as well as mine:
https://github.com/cym13/dirduster

Image source
------------

- Unknown
