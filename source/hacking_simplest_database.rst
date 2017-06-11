=============================
Hacking the simplest database
=============================

A database case study
=====================

In here blog post `Log-structured storage`__ Julia Evans mentions what she
calls the "Simplest database". Behold the entirety of its code:

.. _jvns: https://jvns.ca/blog/2017/06/11/log-structured-storage/

__ jvns_

.. code:: bash

    #!/bin/bash

    db_set() {
        echo "$1,$2" >> database
    }

    db_get() {
        grep "^$1," database | sed -e "s/^$1,//" | tail -n 1
    }

This isn't of course meant to be a practical database, mainly a minimalism
case study. But still it is interesting in some ways. Julia Evans used it as
a minimalist database, we'll use it for a minimalist security code review.

So let's break thing!

.. image:: ../image/rainbowdash_caught_worse.jpg

Privilege escalation
====================

We're essentially reading from and writing to a file. How can this be
exploited? As we already `saw <scr_privesc.html>`_ file operations are often
a vector of privilege escalations.

We will assume that the user using that database is root. It could be another
user but the point is that he's someone worth grabbing the access.

The file is written in the current directory so we face different cases:

The current directory is world-readable
---------------------------------------

No specific set of permissions is set on the file which means it will be
created with the user's umask permissions. In practice this means on most
systems the file will be readable by any user, but writable only by the
owner.

This wouldn't be an issue if the file was kept in a protected directory, but
if in a world-readable one then anyone can just read the content of the
database. Better not store passwords in there.

The current directory is world-writable
---------------------------------------

The file could also be written to a world-writable directory such as /tmp or
/dev/shm.

In that case the exploitation is straight forward: create a symbolic link to
another file, say /etc/shadow. When root tries using the database he will
overwrite or read from that file instead. If we get some control on its data,
all the better. We can get a shell from that.

Data injection
==============

Privilege escalation is good but it requires to have a foot on the system.
What if we only have an access to its data, such as through a web interface?

The easiest thing to do is to perform data injection. Of course in the
current setup it's not very interesting: there is no security mechanism
preventing us to overwrite another data. But what if there was? What if some
keys were off-limit?

Here we can do two types of data injection: comma-based and line-based.

Comma-based injection
---------------------

Fields are limited by commas, but nothing is preventing us to insert commas
in our data. Putting a comma in the value isn't terribly useful because it
would be transparent: only the first comma has a meaning.

On the other hand putting a comma in the key would allow us to redefine
another field.

.. code:: bash

    $ db_set password YouCantTouchMe

    $ db_set password, YesICan

    $ db_get password
    ,YesICan

Fun thing, the second entry is actually still perfectly functionnal:

.. code:: bash

    $ db_get password,
    YesICan

So, should we strip commas off user inputs? Of course not, stripping is very
rarely a good idea. Here we should either escape them by encoding them in
some form, or refuse them altogether.

.. code:: bash

    $ db_set password YouCantTouchMe

    $ db_set pass,word YesICan

    $ db_get password
    YesICan

Line-based injection
--------------------

If commas are unusable we can rely on line injections to get a similar
effect:

.. code:: bash

    $ db_set password YouCantTouchMe

    $ db_set legit "AAAA\npassword,YesICan"

    $ db_get legit
    AAAA

    $ db_get password
    YesICan

Of course the solution is similar to that of the comma example.

Sed injection
=============

I love sed injections because you almost never find one, but when you do it's
practically guaranteed to give you full access.

It's not well-known but sed can execute shell commands, so let's just pop a
shell:

.. code:: bash

    $ db_get legit "We need the database to be not-empty"

    $ db_get "//;e sh #" whatever

That injections forms the following sed command which calls /bin/sh using *e*
and ignores the rest of the line:

.. code:: bash

    $ sed "s/^//;e /bin/sh #,//" whatever


Of course if we were remote we would be using a reverse shell or something
similar. Stopping *e* isn't enough, sed also has commands to write to files
and read from them. This can also lead to remote command execution, for
example by changing the content of an executable file or getting SSH access
by changing ~/.ssh/authorized_keys.

Sed rocks ;)

Conclusion
==========

What is interesting isn't showing how insecure such a simple example is: it
was never meant to be secure in the first place.

No, what's really interesting is that those vulnerabilities are very *very*
common, even in commercial solutions. 5 ways to exploit 6 lines of code is a
nice ratio though ;)

Image sources
-------------

- http://rainbows-dashing.deviantart.com/art/ive-seen-worse-325266232
