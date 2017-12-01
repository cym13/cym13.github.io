=====================================
SSL/TLS configuration recommendations
=====================================

Introduction
============

So you want to deploy SSL/TLS on your service. That's a very good decision.
Services without encryption are not only jeopardizing the provider who may
loose its data and reputation. It may also endanger the users as the
confidentiality and the integrity of the communication is at stake.

But deploying SSL/TLS is easy to mess up so here is a procedure that you may use
to ensure that the result is conveniently secure. This will not correspond to
all situations but it provides a safe basis.

Choosing the configuration
==========================

You should not write your configuration yourself
------------------------------------------------

Unless you're aware of all the possibilities of your webserver and
all cryptographic results that make such algorithm safer than such other one you
won't get it right.

If, on the other hand, you are aware of all the different protocols, encryption
schemes and attacks, then you also know that making a mistake is very probable.
You should therefore not trust yourself.

You should not use the default configuration
--------------------------------------------

The default configuration of most web servers (when they provide one) is not
secure. It is meant to provide something that works without fuss so that you can
proceed with your development. It is not meant to stop an attacker.

.. image:: ../image/kagami-hiiragi-nope-nope.png
    :width: 50%

You should use a configuration generator
----------------------------------------

I strongly recommend using the Mozilla SSL/TLS configuration generator which is
kept up-to-date with the latest security recommendations to make your server
secure.

https://mozilla.github.io/server-side-tls/ssl-config-generator/

By default, choose the "Modern" mode in order to be as restrictive as possible.
If your service can't afford to use TLSv1.2 (and it should) then use the
intermediate mode.

You may notice that a lot of ciphers are proposed by default: indeed it uses the
latest and most secure ciphers known at the time of generation. Many of those
ciphers are often overlooked by non-cryptographers such as
ECDHE-ECDSA-CHACHA20-POLY1305.

If you write this list by hand and do not include those algorithms it means that
even if the client is able to deal with such a high security level the server
won't let it.

A word of caution on HSTS
-------------------------

By default HSTS is enabled in the configuration generator. This may be an issue
if done by mistake because once a website has been loaded with HSTS it is not
possible to load it in HTTP for many month.

HSTS is a very good thing that I recommend using. It is meant to solve the issue
of websites that want to enforce HTTPS and is much safer than setting up a
redirection on the HTTP version to the HTTPS version.

The verification
================

The tools
---------

You wrote your configuration and want to check that it is indeed what your
expect it to be. How can you do?

Mozilla recommends the tool `cipherscan`_ which lists the available cipher
suites proposed by the server. It is a good tool to verify that the
configuration is indeed what you set up.

.. _cipherscan: https://github.com/mozilla/cipherscan

However I prefer `testssl.sh`_. This tool will not only provide you with
the list of exposed ciphers and protocols, it will also warn you of known
vulnerabilities and mis-configurations. Furthermore it will simulate many
connections to determine what cipher suite would be used if you were using what
web client.

.. _testssl.sh: https://testssl.sh/

None of these tools require installation. However keep in mind that while they
may provide good indications they will not supplant a security expert.

The expert
----------

What information will an expert provide that such a tool will not?

These tools are static: they consider the service in complete isolation of the
world and do not try to take in account the context at all. The job of an expert
is to understand that very same context to determine which vulnerabilities are
exploitable. This does not mean that we don't want to fix all vulnerabilities,
but sometimes your software requires very specific ciphers in order to work
properly.

Which brings us to the second task of the expert: what if your software
understands only a vulnerable protocol? What alternative to choose? How to
minimize the risks? An expert is there to answer those questions. Understanding
of what makes a vulnerability riskier than another is what makes him the expert.

Moreover, the expert is the only one that can help after the fact. If your
server proves to be under attack, he is the only one able to tell whether you
can expect the attack to have succeeded and what they attacker can be expected
to have obtained.

If you have a commercial interest in keeping your server secure you should have
its configuration validated by a security expert. You may consider my opinion to
be slightly biased in the matter as that is my job, but at least the bias is
publicly known.

.. image:: ../image/mayoi-hachikuji-yeees.png
    :width: 50%

The tools again
---------------

Security moves fast. A year from now you may be wanting to check that your
server is still as secure as it can be. Security consultants aren't cheap and
you may not want to hire one repeatedly (not that I mind of course).

I recommend regularly updating and using your tools to monitor the state of your
server configurations against current attacks. Of course I have no guarantees
that testssl.sh will get updated appropriately and new attacks without
remediations are always possible so keep an open mind and practice defense in
depth.

Conclusion
==========

In conclusion the protocol I propose is simple and should correspond to most
applications:

- Use the Mozilla generator to bootstrap your configuration in a known-safe
  state

- Test your application. If it doesn't work identify why and make it work by
  making it safer. If that isn't possible, decrease the security of your server.

- Use testssl.sh to check that your configuration was properly loaded and that
  no vulnerability is present. Modify if necessary.

- When possible get an expert to look at your configuration.

- Regularly recheck the configuration using up-to-date verification tools.

What? So no practical advice on what cipher is better etc?
----------------------------------------------------------

No. Those things change, and they should not be left to the choice of
developpers anyway. Let's face it, most developpers are not competent to make
cryptographic choices: it just isn't their job. Let professionals do those
choices for you and spend your time doing what you really like: building
stuff that matters.

Image sources
-------------

- https://www.4chan.org/
