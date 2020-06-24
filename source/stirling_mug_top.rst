=======================
Stirling engine mug top
=======================

Concepts
========

I was reading about `Stirling engines
<https://en.wikipedia.org/wiki/Stirling_engine>`_ and they turn out to be
pretty interesting. They have a number of properties that set them apart from
common engines:

- They rely on the difference in temperature between two plates

- They operate on a closed loop: no fuel needed, no emission produced

- That said you might need to fuel a secondary loop to generate your difference
  in temperature by heating a plate, but it means anything can be used there

- They are very quiet since there is not any explosion or gas emission

- They can be very efficient (up to 50% so comparable to diesel engines)

- They are slow to start but steady once launched

- Since they use temperature difference they are less efficient in hot places

- Smaller engines tend to be more efficient than bigger ones

- They are very same since there is no pressurized gas

.. image:: ../image/Stirling_engine.gif

Clearly these are not fit for everything, but they have already found some
applications especially when it comes to pumping wasted energy back in the
system. For example some submarines use them by exploiting the temperature
difference between the hot inside and cool waters in order to get back some
of the energy that would otherwise heat the ocean.

Application
===========

I was thinking of ways to use this at home and since I have a nice cup of tea
before me it sounds like a good starting point. Let us consider a "mug top"
that doubles as phone charger.

Now a mug contains about 0.3L of water, so about 300g. The energy the mug
gives back to the room by cooling is equal to the energy we invested to heat
it in the first place.

The energy needed to heat 1g of water by 1°C at 25°C is 1 calorie (by
definition) or about 4 Joules. So heating our cup of tea from the ambient
25°C up to 95°C takes about

.. math::

   \frac{(95\text{°C}-25\text{°C}) \times 300\text{g}}{4} \approx 5000\text{J}

Therefore our hot cup of tea is a "battery" of 5000J. As we said, in perfect
conditions our Stirling engine should be able to convert 50% of that energy
to motion, but our tea cup does not present perfect conditions. Much heat
escapes from the sides and our engine will not be a perfect one and we still
need to convert that motion to electric current which adds another conversion
layer.

Let us settle for about 30% efficiency in first approximation to convert heat
to electricity. That represents

.. math:: 5000\text{J} \times 30\% \approx 1700\text{J}

A standard iPhone 8 battery has a capacity of about 1800mAh according to
internet. This will be a good starting point. We need to establish the link
between our raw energy and battery capacity though.

We know that **power = voltage × current**, so **energy / time = voltage ×
current** and **energy / voltage = current × time** or in units **J/V = A×s**.

So to make the link we need to decide on a voltage. Standard 5V should do the
trick. Then we have

.. math:: 1700 \text{J} / 5 \text{V} \approx 340 \text{As} \approx 94 \text{mAh}

These 94mAh represent 5% of our phone battery.

.. image:: ../image/green_tea_miku.png
   :width: 40%

Conclusion
==========

All of this means that, assuming we do not drink our tea until it cools back
to room temperature, we can charge our phone by about 5%. This is not that
great, but it is only using wasted energy which makes it essentially free. And
maybe it would be more useful directly on the teapot or kettle. Damn, think
of simply putting it on top of the lid every time you make pasta. Either way
I do not think this energy is negligible when 4 teas a day represent 20% of a
phone charge.

All in all I would like to see a future in which every household is filled
with little power generators, either limiting energy waste or using green
energies. This would probably not make centralized power plants obsolete but
it could cut our expenses by quite a bit, especially when it comes to power
dissipated when transporting the electricity from distant power plants to our
homes.

Maybe it is worth taking the time to hack a 50€ Stirling engine together with
an electric generator and see what comes out of this.

Image source
------------

- https://en.wikipedia.org/wiki/File:Stirling_Animation.gif
- https://www.deviantart.com/zheartl/art/Green-Tea-Miku-322205748
