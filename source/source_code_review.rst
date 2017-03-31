================================
Fast security source code review
================================

.. image:: ../image/twilight_reading_hard.png
    :width: 60%

The need for FSSCR
==================

There are many situations in which one finds himself wanting to assess the
security of a program or library:

- knowing if the program is secure before choosing to use it
- performing a bug bounty to try and win a few bucks
- making sure our code isn't jeopardizing our users and company
- finding vulnerabilities to assist a penetration test

I couldn't find any extensive documentation on how to make good and fast
code reviews. Getting straight to the point, finding most things in a limited
time is a very useful skill for anyone working in IT security. That's why I
decided to write my own. It will span over a few blog posts of which I'll
incorporate the links here.

Also I want to focus on **finding** bugs. To exploit them please refer to
other documents.

What you'll find
================

There are three kinds of bugs: structural ones, generic ones, and specific
ones.

To enlight better the kind of bugs we're talking about we'll take as example
the `OWASP's Top Ten <https://www.owasp.org/index.php/Top_10_2013-Top_10>`_
which periodically draws the list of the ten most common and important web
vulnerabilities:

1. Injections (SQL, OS, LDAP)
2. Broken authentication and session management
3. Cross-Site Scripting (XSS, a kind of injection really)
4. Insecure direct object reference
5. Security misconfiguration
6. Sensitive data exposure
7. Missing function level access control
8. Cross-site request forgery (CSRF)
9. Using components with known vulnerabilities
10. Unvalidated redirects and forwards

Structural bugs
---------------

They are bugs of design, where the programmer just didn't think of putting
any security in place.

The easiest bugs to find are part of this category because they are quite
high-level, generally don't require to read much code if any. More
importantly they don't require you to know the language used.  You'll
generally find them without any need for a specific analysis method, just
putting yourself in the shoes of an attacker should do.

The following vulnerabilities are part of this category:

- Insecure direct object reference
- Security misconfiguration
- Sensitive data exposure
- Missing function level access control
- Using components with known vulnerabilities
- Unvalidated redirects and forwards

This is more than half of our list. This essentially means more than half of
the most common vulnerabilities are design mistakes and not programming ones.

Not all of them can easily be found during a static analysis though. While it
is by no means impossible if you have access to the live application it is
far easier to just try them directly and see the result.

It is great to test them dynamically. Where there's a number increment it.
Decrement it. Replace it by a quote, some text. Where there's validation go
through anyway and see where it leads you. It often happens that the security
primitives aren't checked even if they're present.

In this scenario source code analysis comes in second: find a bug dynamically
first, then look in the source for similar patterns. Bugs often come in
group.

Some exceptions are the use of vulnerable components, bad cryptography which
can lead to a number of the aforementioned cases and security
misconfiguration. Those are typically easier to see in the code.

Generic bugs
------------

Those are mistakes that are common amongst most languages while still being
programming ones. They are the bugs we are primarily looking for when
performing a source code analysis.

Injections, most broken authentication and session management cases, XSS and
CSRF are part of this category. Not only is this the rest of our list it
contains the three top elements.

These bugs are programming ones. They are the ones for which FSSCR really
shines because they are specific enough for many tools to miss them but
generic enough that we can devise a method to find them.

Specific bugs
-------------

Those are the bugs that make the news.

Subtle off-by-one errors like the `Cryptocat case
<http://www.cryptofails.com/page/23>`_, slight indentation mistakes like
`Goto fail <https://www.imperialviolet.org/2014/02/22/applebug.html>`_,
buffer overruns like `Heartbleed <https://xkcd.com/1354/>`_. They are often
typos where a single character makes the difference. They don't span out of
badly designed or uninformed decisions but are true genuine errors (or
stealthy backdoors_ of course). This makes them both extremely dangerous and
extremely hard to find. They are also often tightly tied to the language
they're written in.

.. _backdoors: https://freedom-to-tinker.com/2013/10/09/the-linux-backdoor-attempt-of-2003/

There are however a number of ways one can approach the code to unveil those
and I might talk about them someday but none of them fits a *fast* code
review so we won't focus too much on them.

If you would like more information though I strongly recommend the book “A
Bug Hunter's Diary” which is too awesome to be left out.

The tools
=========

I use two kinds of tools mainly: discovery and exploration ones.

Discovery tools
---------------

They are all the security related automated source code scanner you can find.
I don't know of any being really generic so you'll have to find one that's
made for the language you study if any. For this reason I don't have much
tools to recommend.

There is no reason not to use discovery tools: if they make your job easier
use them. But be sure never to trust them. They will return false positives
and they aren't likely to find most real security problems.

Special mention for bandit_ in python which is the best tool I've found all
languages considered. It is quite fasts, precise, security-oriented and very
easy to use. It should be part of any project's automated testing stack.

.. _bandit: https://github.com/openstack/bandit

Exploration tools
-----------------

Those are the screwdrivers of our toolbox: rough but deadly efficient.

I spend 90% of my time using the following GNU/Linux tools:

- GNU Coreutils (bash, grep, sed... Useful to filter and format information)
- vim (what could I do without a good text editor?)
- ranger_ (an excellent file manager that I love for its preview mode)
- gg_ (a recursive grep on steroid in pure bash that I wrote)

.. _ranger: http://ranger.nongnu.org/

.. _gg: https://github.com/cym13/gg

Know thy enemy
===============

As always the exploration phase is the most import part. Getting familiar
with the code base is what will make you efficient in the next steps of the
analysis.

See it live
-----------

If you have access to the live tool (eg: a website) visit it. Identify the
points of interest (Is there authentication? What is the website trying to
protect? What are the interaction points?).

Get a feel of the vocabulary
----------------------------

Many companies like defining their own world, calling customers "rabbiters"
and items "carrots" for example. Get yourself in their world. For example,
when studying a video game there is no point in searching "user_cart" if they
call it a "player_booty". Are they talking about passwords, keys, tokens or
secrets?

Identify what you can ignore
----------------------------

There is generally a lot you can ignore. I usually maintain two copies of the
source code for big missions: one is the original, the other is the work
version where I systematically delete any file that I don't think I need
anymore. It can be resources, photos, near empty files as well as files that
aren't likely to present any more vulnerability.

This is all about reducing the cognitive load: getting less grep hits, less
garbage to filter out, less files to think about. The secret to being fast is
avoiding any unnecessary work.

Start with the lowest fruits
============================

.. image:: ../image/after_a_hard_day_of_applebucking.png
    :width: 50%

There is no need to build a boat where there is a bridge. The key here is to
focus on what is directly available.

If you are doing a security audit checking the dynamic parts we discussed in
the structural part would go there. I won't talk about it there though.

Outdated software is the first thing to look for. CVEDetails_ provides data
on most known vulnerabilities, you can use it as reference.

.. _CVEDetails: http://www.cvedetails.com/

If examining a client software look for misplaced logic. Any input validation
or query building should be on the server-side. If not there is a good chance
it's not properly validated on the other end. There is no need for SQL
injection if the client is allowed to run any query it chooses.

After that look for passwords and other sensitive information hard-coded in
the project's file. *gg* is your friend. This is not without link with the
previous point: if there is direct access to a SQL server for example there
needs to be credentials somewhere readily available.

::

    Keywords: password passw pwd key token secret

If this doesn't give anything try it the other way around: identify places
where they might make use of a hard-coded secret: use of an external service,
development services which usually have weak passwords, etc. Try to adapt
your vocabulary. Leverage your exploration phase fully.

Cryptography, the great forgotten
=================================

The last low fruit is cryptography. Cryptography has a reputation of being
impossible to grasp although identifying flaws is often quite easy in
practice. It is easy to screw up, even security professionals generally shy
away from it, finding common flaws is easy and if there's encryption there's
definitely something worth finding.

This makes it the perfect think to look for in a FSSCR. I will dedicate a
whole article to the subject but here are some starters:

- Missing encryption is worse than bad encryption. Is there any connection
  that should use HTTPS and isn't? Does the service allow us to bypass the
  encryption in any way? Is the original data really annihilated?

- Encryption without authentication can never be useful. For example an HTTPS
  connection that doesn't check the validity of the certificate just enforces
  that the communication between the application and the recipient is kept
  secret. It doesn't help much if the recipient is actually the attacker.
  Note that a shared secret counts as authentication: I prove that I am who I
  say I am by providing this password only you and me know.

- You are likely to find the name of the encryption scheme used such as
  "AES265-CBC-PKCS1" or hash algorithms like "MD5". Just look it up on the
  internet, you're likely to find many people asking about it. If you find no
  answer then you might be against something exotic which is dubious at least.

- Cryptography needs real randomness. Use of the default random number
  function provided by the language or, worse, of time or constants **will**
  result in vulnerabilities.

::

    Keywords: crypt cipher rand hash time secret obfuscate

There are much more that could be said of course, but those four points will
keep you running. Such flaws really are incredibly common.

The error lies in the interface
===============================

Most bugs don't happen where the code is well managed with its internal
logic, it happens at the interface, at the boundary of two worlds where the
logic shifts from a rule set to another.

All injections are a problem at the interface of two languages:

- XSS: webserver language v/s HTML and JavaScript
- SQL injection: application language v/s SQL
- Shell injection: application language v/s shell
- XML External Entity: XML v/s DTD
- Eval misuse: application language v/s application language as text
- Deserialization issues: application language v/s serialized language
- ...

All those are very important issues that only happen in very specific code.
This makes it easier to find them: just look for interface code.

Find code that manipulates text, preferably directly with string
concatenation rather than through library functions that may perform
escaping. Look for code dealing with well-known interfaces such as XML
parsing, data serialization or SQL queries.

Learn about the edge functionalities of the format and library used. Most XML
parsers accept DTD by default, yaml has directives to execute shell code and
Perl's open will execute commands if the right filename is given.

All those vulnerabilities lie on the same principles: one should always make
sure when interpreting something that what is data remains data and what is
code remains code. Shell injections through file names, XSS through link
URLs... If it's data it should be escaped without thinking twice about it.

::

    Keywords: exec system process query open load send read

Privilege escalations
=====================

There are other kinds of interfaces that can be exploited, like the boundary
between user permissions. This is where privilege escalations dwell.

The idea of a privilege escalation is to gain more rights than you have by
getting a privileged process to some execute code on your behalf. This can be
done legitimately as with sudo on GNU/Linux systems.

However bugs like race conditions, bad error handling, untamed imports can
lead the process to execute code that wasn't intended to be executed. The
vulnerable application is then compelled to execute code on behalf on another
process.

Check any file manipulation. Is the file that you opened really what you
think it is? Could someone have had swapped it with a symbolic link while you
weren't looking? Are the tests well performed and the exception handled? What
files are you importing, is that DLL really the one you think it is? Are all
paths unambiguous?

It doesn't matter how slim the possibility really is because privilege
escalation is a domain where the attacker has an advantage: as he is already
on the system he has access to a lot of information on the permissions and
can try as many times as he wants to trigger an unstable bug. He only needs
to get it right once.

::

    Keywords: open file read write rename chmod islink exists loadlibrary exec

More in the `dedicated article <scr_privesc.html>`_.

Of course not all kind of applications will be susceptible to privilege
escalations. There are lots of bugs that are in some way application
specific. CSRF attacks or session fixations for example do not target
anything but web applications. What is important is to learn and recognize
the kind of bugs that is specific to your application.

The language barrier
====================

Maybe you've noticed that we didn't talk about any specific programming
language yet. It is because all the bugs we saw are largely language
agnostic.

Language specifics
------------------

Of course this doesn't mean that the programming language doesn't matter.
Some languages like Perl or Ruby strive on proposing many ways to do the same
thing which complicates the analysis, contrary to languages like Python that
try to propose one default way to do the work. Multiple syntaxes mean more
time to search the same kind of operations.

Also all languages have their specificities. Ruby is one of the only
languages that uses multi-line regex by default for example. This means that
there might be bugs if the programmer uses "^" and "$" instead of \\A and \\Z
to match the beginning and end of line. Similarly in Lua array indexing
starts at 1 so subtracting one to the length of the list won't give the
index of the last element, that could cause an off-by-one bug.

To find language specific bugs the experience you have with the language
matters a lot. But to find the generic bugs we listed before, not so much
actually.

A shell injection will always be a shell injection, no matter what language
it's written in. If you don't know the language just look up what functions
and syntax can be used to perform shell execution and look for it. Most
languages share the same names for common functions.

Manual memory management
------------------------

There is however one class of languages that hides a whole category of very
specific and powerful bugs: those with manual memory management, and first
and foremost the C programming language.

C (and C++ with it) has a whole class of bugs that hardly ever happen in any
managed language such as Python, Java or C#:

- uninitialized memory
- buffer overflow
- double free
- use-after-free
- pointer arithmetic error

To those I'd like to add "integer overflow" which many high-level languages
such as Python or Perl avoid gracefully, but I can't count Java and C#
amongst them.

The reason is simple, by giving the programmer more leverage to manage his
memory there are more times where the memory isn't managed as it should.

If you study C programs, those bugs are important and generally hard to find.
I strongly recommend using tools such as cppcheck_ or scan-build_ to help you
in this task.

.. _cppcheck: http://cppcheck.sourceforge.net/

.. _scan-build: http://clang-analyzer.llvm.org/scan-build.html

We won't talk about them here because they deserve much more than a few lines
in a blog post. However, remember that all the bugs we talked about earlier
are also present in C programs.

Going further
=============

.. image:: ../image/fluttershy_mane_in_wind.png
    :width: 40%

There is of course much more to say about code reviews. I will write more
detailed articles about some points I glanced over in this post and update
this page in circumstance.

If you want to go further here are some resources that I found interesting:

- `A Bug Hunter's Diary`__
    Complete analysis by Tobias Klein of some bugs he found, how he found
    them and how they could be exploited. Very low-level, but very
    enlightening.

.. _bughunter: http://www.trapkit.de/books/bhd/en.html

__ bughunter_

- `How to Perform a Security Code Review for Managed Code`__
    An article by Microsoft explaining their review method. Very thorough.

.. _microsoftscr: https://msdn.microsoft.com/en-us/library/ff649315.aspx

__ microsoftscr_

- `A bite of Python`__
    Python specific tips and tricks for security reviews.

.. _bitepython: https://access.redhat.com/blogs/766093/posts/2592591

__ bitepython_

- `Attacking Ruby on Rails Applications`__
    Phrack article on common pitfalls of Rails applications.

.. _attackingror: http://phrack.org/issues/69/12.html

__ attackingror_

- `Unexpected Journey #3`__
    A good example of what a *fast* code review can look like.

.. _unexpectedjourney: https://pentest.blog/unexpected-journey-3-visiting-another-siem-and-uncovering-pre-auth-privileged-remote-code-execution/

__ unexpectedjourney_

Have fun!

Image sources
-------------

- http://mlpfanart.wikia.com/wiki/File:Twilight_Sparkle_reading_vector.png

- http://drewdini.deviantart.com/art/After-a-Hard-Day-of-Applebucking-314492258

- http://uxyd.deviantart.com/art/Windswept-Fluttershy-349655849
