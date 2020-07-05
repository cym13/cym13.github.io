=======================
Stream of Consciousness
=======================

*Random ramble at the edge of reason.*

----

**Sun 05 Jul 2020 10:55:52 PM CEST**

Since Boehm GC scans the stack for things that look like pointers to objects,
could we "plant" an address to a dead struct then remove it to trigger a
double free just by manipulating stack data?

----

**Sun 05 Jul 2020 01:30:27 PM CEST**

`Sora Yori mo Tooi Basho
<https://myanimelist.net/anime/35839/Sora_yori_mo_Tooi_Basho>`_, “A place
further than the universe”...

There are many feel good stories following the life of a group of high school
girls, but none like SoraYori. It's a story of unlikely peple running away
to discover something more in their lives. The kind of story that would
motivate anyone to try anything. A story about learning what friendship
means, what making a choice means, what being alive means. A story about
doing the impossible no matter what.

A story about Antartica.

Each of the four unlikely friends has a strong personnal development which is
hard to do in only 13 episodes yet the producers manage it perfectly. The
show is well written to the point where even background characters feel alive
and unique. The artistic direction is also extremely good and I found myself
thinking several times that they way the image was framed or cut was very
ingenious. It served to present its subject with emotion and tact.

Definitive recommendation to anyone.

----

**Fri 19 Jun 2020 03:07:25 PM CEST**

You know how in fantasy stories there's always a huge prophecy that the hero
will defeat the forces of evil? It always bugs me that, when the main
character and prophesized hero comes, basically no country bothers raising an
army or trying to deal with the issue by itself. It's all „Well, we can't do
anything about it anyway, it's all in the hero's hands”. And fortunately it
turns out ok because prophecies in fantasy novels are always right.

I'd like a board game about that. Let's call it Prophecy.

Players could be "prophesized hero" but we'd have no way to know which is the
actual hero (or if one even is a hero). The goal would be to stop waves of
monsters and finally the demon Lord after a set number of rounds.

Fighting waves of demons can be done either by convincing countries to raise
an army or by becoming strong in their own right and fighting the horde
yourself. But the demon Lord would be special and require either a one-on-one
combat with the true hero of the prophecy or an army gathering all nations of
the world.

If someone fights off a wave alone its reputation grows, bards chant his name
and countries start getting lazy because they've found the hero or so they
think. This makes it harder to motivate them to raise an army. On the
contrary if people do not trust our heroes raising armies will be easier but
they are less likely to do as the hero says and in particular let them fight
one-on-one or set aside diplomatic issues to gather all armies of the world.

Players win if the world survives the demon Lord.

Maybe there should be something if a true prophecy was made but the true hero
wasn't found or decided not to fight the demon Lord... It sounds cool but I'm
not sure how it fits the rest of the game.

The actual mechanics behind all that are...not there. But I like the ideas and
concepts and I think it could be as simple as a card game where people have a
face-down card indicating whether they are the true hero and action cards
that are spent on convincing other countries to act as we'd like them too.
Monster waves would be a deck of cards too, last of which is the demon lord,
and each turn a card is turned face up to know what horrors invaded the
country.

I'll have to think more about all this.

----

**Fri 19 Jun 2020 02:30:05 PM CEST**

Just had a nice thought... Is there a real x such that x^x=i ?

Suppose by contradiction

.. math:: x \in \mathbb{R}, x^x=i

Then,

.. math::

   \ln(x^x) = \ln(i)

   x\ln(x) = \ln(i) = \ln(e^{i\frac{\pi}{2}}) = i\frac{\pi}{2}

   \implies x\ln(x) = i\frac{\pi}{2}

But

.. math:: x^x=i \implies x\ln(x)=\frac{\pi}{2} x^x

Then, by taking the derivative on both sides

.. math:: \frac{2}{\pi} (1+\ln(x)) = x^x \cdot (1+\ln(x))

We can't simplify if 1+ln(x)=0 which happens for x=e^-1, so let's consider
that case first.

.. math::

    x = e^{-1} \implies e^{-1}\cdot\ln(e^{-1}) = i\frac{\pi}{2}

    \implies -e^{-1} = i\frac{\pi}{2}

which is false. So e^-1 can't be solution of our equation. Let's continue
with x≠e^-1 by simplifying left and right the (1+\ln(x)) term:

.. math::

    \frac{2}{\pi} = x^x

    \frac{2}{\pi} = \frac{2}{\pi} x\ln(x)

    1 = x\ln(x)

    e = x^x

But as previously established

.. math::

   x^x = \frac{2}{\pi} \implies e = \frac{2}{\pi}

Which is false. Therefore since supposing the existence of a solution leads
only to contradiction we proved that no real number is solution.

.. math:: \nexists x \in \mathbb{R}, x^x=i

Nothing groundbreaking, just a thought. It's funny how all my proofs end up
being proofs by contradiction one way or another even though it is frowned
upon in serious circles.

----

**Wed 17 Jun 2020 07:43:58 PM CEST**

I just tried cooking Corned Beef for the first time.

With the whole Covid-19 thing I noticed that my main issue with food wasn't
longevity but diversity and while I had no issue finding really good canned
fish, beef was another matter entirely.

And now I think I know why. It's pretty strange stuff. The can I used was as
"pur" beef as you can get, 98.7% beast and a dash of salt and E250. The smell
is not nice. You can get used to it I think. It's has a vibrant red color
which, for some reason, didn't change at all when cooked in a hot pan. This
is unusual. Beef turns grey normally when cooked. This did not change color a
bit. There's no colourant indicated though. Weird.

I had some rice and pasta leftovers so I mixed them all in a hot pan with a
dash of olive oil and the meat. Really basic, just to get a feel of the food.
I ended up adding quite a lot of black pepper and garlic as well as some hot
pepper and salt. I would really have liked an onion but there was none to be
found. Generally trying to overspice food is not a good sign, and rightly so,
but now it kind of smell like american hamburgers, where there is more spice
and herbs than actual meat.

Weird. Not bad though. Bit too much to pepper.

Will I start pilling beef cans in my stock? Probably not. The taste isn't
worth it and these cans are too big for a single meal so I'm stuck with it
for the next day at least. I would much rather have more kind of fish cans
and complete dishes such as canned raviolis in case I really start craving
meat. Still, this was a nice experience overall.

