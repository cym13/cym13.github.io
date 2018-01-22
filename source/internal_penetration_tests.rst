==========================
Internal Penetration Tests
==========================

Introduction
============

Penetration testing covers a very wide range of topics, targets and
methodologies. Of all this possibilities there is possibly none that is more
representative of the field than internal penetration tests. Being on a
company's network looking for servers to take control of, then bouncing from
an account to another until the whole network is ours is what most people
have in mind when hearing across the cocktail "Yeah, I'm paid to hack into
banks and stuff".

That said, performing such assignments can sometimes be overwhelming. I do
not want to write a thousand page long book on internal pentests, but I'd
like to share some tips and methods to grasp the low-hanging fruits and get a
starting point. You'll soon find out that the method we describe here almost
never works directly on the field and that everybody has his pet techniques
to get the best of the customer's network.

Starting line
=============

Ok, so you're somehow on the internal network. Could be the Wi-Fi, a VPN, a
dangling RJ45... What matters is that your shell's waiting and your customer
knows that you're there. These techniques absolutely do not care about being
discreet so if you were looking for a practical black hat handbook you'd
better get back on IRC make some friends. On the other hand, contrary to a
black hat, we don't have months to carefully auscultate the network so we'll go
for the fastest.

.. image:: ../image/chibi_mahou.png
    :width: 40%

**The first thing you want is to know what's around you.**

Take note of your IP range and start looking for other hosts:

- Fire up tcpdump or wireshark. You may record other's requests, see
  broadcast calls, etc.

- As soon as you get an idea of what the internal top level domain name is
  (or just guess it's ".int"), ask for a DNS zone transfer with `dig AXFR
  int.`. That will very often give you the almost full list of all existing
  hosts within the network.

- Perform an ARP search, both passive and active, using netdiscover_.

- Perform a ping sweep using nmap.

- Avahi-discover_ can bring out surprising things if some station speaks the
  Hello protocol such as Macs.

- If IPv6 is enabled you may want to sweep it too and look for
  misconfigurations. I won't delve into it now though.

.. _netdiscover: https://sourceforge.net/projects/netdiscover/

.. _Avahi-discover: http://www.avahi.org/

At that point you should have a growing list of IPs and hostnames. It's time
to start exploiting these information.

Identification
==============

This is a quick but important step: try to identify what those hosts are.
We're not at a point where we're firing nmap up in every direction as that's
generally way to long. But you might do so on a sample of hosts in order to
get a general feeling.

Is the network mainly Windows based? Do we see signs of actual users on the
network (such as UDP packets in broadcast sent by mouses_, Avahi hosts or the
"catherine-iphone" kind of hostname)? In any case it's worth setting a
Responder_ up as soon as possible.

.. _mouses: https://www.pcweenie.com/content/logitech-arx-my-asx
.. _Responder: https://github.com/SpiderLabs/Responder

.. image:: ../image/chibi_mouse.png
    :width: 40%

Does it look like it is mainly composed of Linux servers? We want to take
that into account when doing our port scans later.

Weak services discovery
=======================

We don't want to just `nmap -AO -T4 10.0.0.1/16` our way in. Scanning the
whole network just takes too much time. Or more precisely we want to do that
ultimately, but first we'll perform targeted scans to identify weak points
that will give us something to do while port-scanning the universe.

This is where the identification phase comes in handy. We'll perform a
targeted port scan of the hosts we found earlier. We'll limit ourselves to
few ports that are often available and misconfigured.

What we're interested in is:

- FTP
- Telnet
- HTTP
- HTTPS
- Alternate HTTP ports (8000, 8080, etc)
- SNMP
- SQL
- ...

This list is to be adapted depending on what you expect to find. For example
if it looks like there are lots of Linux hosts it wouldn't be strange that
some of them are available through SSH with `root/<empty>` as credentials.
Because typing passwords or using keys is so hard you know. These kind of
basic errors is what we're looking for in the next section.

Automatic data collection
=========================

So we have a list of hosts with web servers, lots of telnet access points
etc... As always in internal penetration testing, the challenge is the
amount of data generated. That's why we want to automate as many things as
possible.

So we'll /bin/bash our way through by testing default credentials on all
hosts depending on their services. `root/root`, `root/<empty>`,
`root/password` and `admin/admin` are paramount at this point. We want to try
automatically connecting to FTP and Telnet ports using these.

We also want to download each main page of each webserver we found. This will
allow us to grep your way through them to know whether there is a login page,
whose are printer configuration pages, how many of them are identical meaning
that the servers that host them are probably too...

Internal web services generally are a goldmine. Default passwords never let
me down when there are passwords at all. Also, internal services are often in
plain HTTP so if you're able to setup a Man in the Middle it becomes
tremendously easy to get into new things.

Stepping back a bit
===================

By this point you may already have a lot of NTLM hashes from Responder and a
solid list of targets.

Don't hesitate to launch a more extensive nmap scan at this point, you'll
take some time digging trough the results anyway. Similarly it's a good point
to start cracking passwords.

Bruteforcing up to 6 or 7 characters is always a good thing when possible but
I tend to privilege dictionary attacks. Aside from the famous RockYou_ that
surprisingly still gives results from time to time, my favorite method is to
use 1337dict_ which is a 1337-speak password generator.

It turns out that the oracle database administrator's password is often
something like `dbAdm1n@Oracle`. Similarly John Penfield that entered the
company in 2016 never bothered changing his mail password from the default
`jpe2016`. So we want to use intelligently the data we have at our disposal:

- Employee names? In!
- Company name? In!
- All years or dates from the creation of the company? In!
- Yet keep in mind that this grows the search time exponentially.

You get the idea. Efficient password cracking is an art, but terribly
powerful when mastered.

.. _RockYou: https://wiki.skullsecurity.org/Passwords

.. _1337dict: https://github.com/cym13/1337dict

Ok, and now?
============

So, you somehow got into something. Could be a web application, a mailbox, a
workstation... I'll take that last example as it's the easiest to deal with.

Look for accesses to other computers:

- What's shares are mounted? Explore them.

- What application or script may exchange data with other hosts? Look into
  scripts and configuration files. Most passwords are in `config.ini`, not
  `password.txt`

- Still, look for `password.txt`... Many organizations keep a single XLS with
  all passwords in the Public share.

- Look for password history within the web browser.

Then once you have more passwords you can start bouncing to other hosts,
finding more passwords, finding more hosts...

This is the point where you want to call your customer and have him
prioritize because you're never going to have the time to exploit
*everything*.

.. image:: ../image/youmu_konpaku_sigh.png
    :width: 40%

Conclusion
==========

The true difficulty of this kind of assignments is the time. Most company
networks have so many obvious flaws that you will rarely find yourself in
need for actual exploits or protocol reverse engineering on the fly (note
that I don't hope you get some of those too, they're great fun).

The sheer amount of data to sort and exploit is often the main reason why we
end up stuck wasting the day reading nmap scan reports while not actually
knowing what to do with them. I hope this article provides some answers as to
how to manage that complexity.

Image sources
-------------

- https://yoai.deviantart.com/art/happy-halloween-569514306

- https://ninetail-fox.deviantart.com/art/My-mouse-chibi-257200172

- https://yukirumo990.deviantart.com/art/Youmu-Konpaku-251134451
