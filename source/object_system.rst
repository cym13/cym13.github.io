=============================
Let's build an object system!
=============================

After-thougt warning
====================

If you are seeking a read-only article that will expose how things work in
reality, you are at the wrong place. Honestly, I think that if you fully
understand everything just by reading this, you didn't have anything to learn
in the first place.

This is a story of experimentation. It is meant as a guide to
experimentation, for you to try your own things and come with your own
conclusions with only a little push of mine. I can't (and wouldn't) force you
to try those things while reading, but I sure advise you to do so.

Introduction
============

Hey, I sort of feel like building an object system, so let's do it together!
It will be in python for a high-level language is well suited to that kind of
experimentations. And as this is somewhat improvised, I hope it won't be too
messy.


We first need a subject, so let's talk about cats. That's not because animals
are the classical subject for object oriented programming, but mostly because
they are just damn too cute.

First approach
==============

What do we want to talk about... A name, an age, a color and a breed should
do it. We also want him to mew and purr. Let's be naive:

.. code:: python

    age   = 3
    name  = "Kitty"
    color = "blue"
    breed = "russian blue"

    def mew():
        print(name, "mews!")


    def purr():
        print(name, "purrs!")

That's great, everything is easy to access and modify. But it will soon be a
mess if we need a second cat. We could end each variable name with _1 or _2
but what about when we want to have an infinite number of cats (because who
doesn't want a universe full of cats)?

For this reason, we need a way to structure things, to say that they are
linked together, to manipulate them accordingly and to create them easily.
That's what an object system is.

Structuring things
==================

We're in python where the list is the most common data structure, so it seems
logic to give it a try. We will base our system on a convention. First the
age, then the name etc...

.. code:: python

    mycat = [3, "Kitty", "blue", "russian blue"]

    def mew(cat):
        print(cat[1], "mews!")

    def purr(cat):
        print(cat[1], "purrs!")

That definitely looks better, but relying on a convention can be hard if
another programmer has to look at your code.

Also, the actions are left alone... We're in python, a function can be put in
a list too!

.. code:: python

    def mew(name):
        print(name, "mews!")

    def purr(name):
        print(name, "purrs!")

    mycat = [3, "Kitty", "blue", "russian blue", mew, purr]

    mycat[4](mycat[2])
    #> Kitty mews!

The advantage is that one can change how a cat mews without changing every
cat:

.. code:: python

    def mew(name):
        print(name, "mews!")

    def purr(name):
        print(name, "purrs!")

    kitty = [3, "Kitty", "blue", "russian blue", mew, purr]

    def nyoron_mew():
        print("Nyoron says nya!")

    nyoron = [2, "Nyoron", "white", "bobtail", nyoron_mew, purr]

    kitty[4](kitty[2])
    #> Kitty mews!
    nyoron[4]()
    #> Nyoron says nya!

The problem is that it lacks a common interface, with that structure you
can't know in advance how to make a cat mew... Let's solve this:

.. code:: python

    def nyoron_mew(name):
        print("Nyoron says nya!")

    def mew(cat):
        cat[4](cat[2])

    def purr(cat):
        cat[5](cat[2])

    kitty  = [3, "Kitty",  "blue",  "russian blue", default_mew, default_purr]
    nyoron = [2, "Nyoron", "white", "bobtail",      nyoron_mew,  default_purr]

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron says nya!

Nice isn't it ? If all we want to do is making them mew or purr we don't even
need to know how they are implemented. It would be nice to have the same
thing at creation...

Constructor
===========

.. code:: python

    def make_cat(age, name, color, breed):
        def default_mew(name):
            print(name, "mews!")

        def default_purr(name):
            print(name, "purrs!")

        cat = [age, name, color, breed, default_mew, default_purr]
        return cat

    kitty  = make_cat(3, "Kitty",  "blue",  "russian blue")
    nyoron = make_cat(2, "Nyoron", "white", "bobtail")

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron mews!

Shit, we forgot to change Nyoron's mewing... But how can we do it without
knowing how it is implemented? We need a special function for that.

.. code:: python

    def make_cat(age, name, color, breed):
        cat = [age, name, color, breed, default_mew, default_purr]
        return cat

    def change_mew(cat, new_mew):
        cat[4] = new_mew

    kitty  = make_cat(3, "Kitty",  "blue",  "russian blue")
    nyoron = make_cat(2, "Nyoron", "white", "bobtail")

    def nyoron_mew(name):
        print("Nyoron says nya!")

    change_mew(nyoron, nyoron_mew)

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron says nya!

That's better! Now we have a nice layer of abstraction and can change how a
cat is represented without breaking everything. But we need a function to
change or get the value of each attribute of our cat... Maybe lists aren't
the way to go.

Dictionaries
============

.. code:: python

    def make_cat(age, name, color, breed):
        def default_mew(name):
            print(name, "mews!")

        def default_purr(name):
            print(name, "purrs!")

        cat = {'age':   age,
               'name':  name,
               'color': color,
               'breed': breed,
               'mew':   default_mew,
               'purr':  default_purr}
        return cat

    kitty  = make_cat(3, "Kitty",  "blue",  "russian blue")
    nyoron = make_cat(2, "Nyoron", "white", "bobtail")

    def nyoron_mew(name):
        print("Nyoron says nya!")

    nyoron['mew'] = nyoron_mew

    kitty['mew']()
    #> Kitty mews!
    nyoron['mew']()
    #> Nyoron says nya!

That's nice, really nice! We can do a lot with that! It seems so easy, of
course dictionaries were the way to go!

For information python and javascript object systems are built on this very
principle with just a little syntactic sugar to make it nicer. If you don't
trust me, you could do (in python):

.. code:: python

    class A():
        def __init__(self):
            self.value = 42

    a = A()
    print(a.__dict__)
    #> {'value': 42}

Layers of abstraction: comeback
===============================

Note that we lost a bit of portability by using the dictionary directly: if
we want to change the internal name for mewing, we can't without changing all
calls to that method.

This is easily solved with a method that we saw before.

.. code:: python

    def make_cat(age, name, color, breed):
        def default_mew(name):
            print(name, "mews!")

        def default_purr(name):
            print(name, "purrs!")

        cat = {'age':   age,
               'name':  name,
               'color': color,
               'breed': breed,
               'mew':   default_mew,
               'purr':  default_purr}
        return cat

    kitty  = make_cat(3, "Kitty",  "blue",  "russian blue")
    nyoron = make_cat(2, "Nyoron", "white", "bobtail")

    # We will do generic functions. They are simple now, but give us the
    # possibility to change things later by gluing code together.

    def getatt(cat, attr_name):
        return cat[attr_name]

    def setatt(cat, attr_name, value):
        cat[attr_name] = value

    # Some specific functions, that's just syntactic sugar
    # Note that as we don't know the function, we take every precaution
    def mew(cat):
        return getatt(cat, 'mew')()

    def purr(cat):
        return getatt(cat, 'purr')()


    def nyoron_mew(name):
        print('Nyoron says nya!')

    setatt(nyoron, 'mew', nyoron_mew)

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron says nya!


A proper class
==============

Ok, so now we have a simplistic yet working object system. However, did you
notice the nice circle we just did? We started with an object system because
we had functions and variables everywhere and now we have functions
everywhere all over again!

The solution is easy: let's make an object that manages other objects! That's
what a class is.

So, we learned our lesson, we need a constructor, getters, setters and some
internal organisation convention. Some sugar would be cool too! We will skip
some of those here because most of the time a class isn't instanciated more
than once, but if you know how to implement it if you need to.

.. code:: python

    def make_cat_class():
        def make_cat(age, name, color, breed):
            def default_mew(name):
                print(name, "mews!")

            def default_purr(name):
                print(name, "purrs!")

            cat = {'age':   age,
                   'name':  name,
                   'color': color,
                   'breed': breed,
                   'mew':   default_mew,
                   'purr':  default_purr}
            return cat

        def getatt(cat, attr_name):
            return cat[attr_name]

        def setatt(cat, attr_name, value):
            cat[attr_name] = value

        cat_class = {"new": make_cat,
                     "get": getatt,
                     "set": setatt}
        return cat_class


    cat = make_cat_class()

    kitty  = cat["new"](3, "Kitty",  "blue",  "russian blue")
    nyoron = cat["new"](2, "Nyoron", "white", "bobtail")

    def mew(cat):
        return cat["get"](cat, 'mew')()

    def purr(cat):
        return cat["get"](cat, 'purr')()

    def nyoron_mew(name):
        print('Nyoron says nya!')

    cat["set"](nyoron, 'mew', nyoron_mew)

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron says nya!

This seems tedious... We will see later that this method has its advantages,
but for now you may like to know that python's designers thought that it was
tedious too. That's why instead of implementing it with special functions
they used special keywords ("class") and conventional function names such as
__init__() for the constructor. Those magic names are called automatically
by python itself when creating a new object.

That also means something really interesting: a class is just an object!
That's not true for every object system but it is for most, and python is one
of them:

.. code:: python

    class A()
        def __init__(self):
            self.value = 42

    print(A.__dict__)
    #>{'__module__': '__console__',
    #  '__init__': <function A.__init__ at 0x7fc88f053a60>,
    #  '__dict__': <attribute '__dict__' of 'A' objects>,
    #  '__wea kref__': <attribute '__weakref__' of 'A' objects>,
    #  '__doc__': None,
    #  '__getattribute__': <slot wrapper '__getattribute__' of 'object' objects>
    # }

Subclassing
===========

If you come from C, nothing we have done so far should have impressed you. In
fact, you must be laughing at how hard it seems to do in python what you
would have easily done using a structure with some function pointers. Well,
you would be laughing if you didn't know that this is a very unpythonic way
to do things. But we will see something that is hard to do beautifully in C
with structure: subclassing and inheritance.

We saw before that a nice side effect of our tiny object system is that it
makes dealing with special cases easier (what we did with mew() for Nyoron).
We also saw that, at least in our system, a class is just some special object.

Let's specialize then! We could say for example that all bobtail cats are
japanese (they are not called "japanese bobtail" for nothing after all) and
that their default mewing is "Nya!". They also give luck.

.. code:: python

    def make_cat_class():
        def make_cat(age, name, color, breed):
            def default_mew(name):
                print(name, "mews!")

            def default_purr(name):
                print(name, "purrs!")

            cat = {'age':   age,
                   'name':  name,
                   'color': color,
                   'breed': breed,
                   'mew':   default_mew,
                   'purr':  default_purr}
            return cat

        def getatt(cat, attr_name):
            return cat[attr_name]

        def setatt(cat, attr_name, value):
            cat[attr_name] = value

        cat_class = {"new": make_cat,
                     "get": getatt,
                     "set": setatt}
        return cat_class


    def make_japanese_cat_class():
        # We don't need to redefine everything, just what we want to change
        def make_cat(age, name, color):
            def default_mew(name):
                print(name, "says nya!")

            def default_purr(name):
                print(name, "purrs!")

            def give_luck(name):
                print(name, "gives you luck!")

            cat = {'age':   age,
                   'name':  name,
                   'color': color,
                   'breed': 'bobtail',
                   'mew':   default_mew,
                   'purr':  default_purr,
                   'luck':  give_luck}
            return cat

        cat = make_cat_class()
        cat['new'] = make_cat
        return cat

    cat = make_cat_class()
    jap = make_japanese_cat_class()

    kitty  = cat["new"](3, "Kitty",  "blue", "russian blue")
    nyoron = jap["new"](2, "Nyoron", "white")

    def mew(cat):
        return cat["get"](cat, 'mew')()

    def purr(cat):
        return cat["get"](cat, 'purr')()

    def luck(cat):
        return cat["get"](cat, "luck")()

    mew(kitty)
    #> Kitty mews!
    mew(nyoron)
    #> Nyoron says nya!

    luck(nyoron)
    #> Nyoron gives you luck!
    luck(kitty)
    #> Traceback (most recent call last):
    #  File "<input>", line 1, in <module>
    #  KeyError: 'luck'

As we can see, it is quite easy to define new classes based on the existing.
As it is our system doesn't allow us to reliably inherite from many classes,
we would have to add some way to merge two classes without getting any name
clash while still having all the functionalities. You could try as an
exercise, it is not an easy problem but it is an interesting one.

Also, as we can see from the last line we have no way to tell what the type
of a given object is right now. It is not hard to get this done, we just need
to add a name attribute to our class and a class method to check wether an
object is of this class or not.

Another strategy is to build on the error that was raised when we executed
the last line. Following the principle that asking for forgiveness is better
than asking for permission, we can just try the method on the object at hand
and see if it works. If it works, then the object had a method of this name,
good for us (checking the result would be a good idea though). If we get an
error, that's okay, it just means that it wasn't the right object.

This strategy is known as duck-typing: "If it floats and quacks as a duck, it
may not be a duck but it sure is close enough for it to be my diner". This
powerful strategy is not without link with the java adage "program to an
interface, not an implementation". I say java because it was popularised in
this context, but it really is a good general advice.

Subclassing is a very important feature of object oriented programming, and
in many high-level languages today everything is object by subclassing.
Confused? Look back at our previous example with the A class:

.. code:: python

    class A()
        def __init__(self):
            self.value = 42

    print(A.__dict__)
    #>{'__module__': '__console__',
    #  '__init__': <function A.__init__ at 0x7fc88f053a60>,
    #  '__dict__': <attribute '__dict__' of 'A' objects>,
    #  '__wea kref__': <attribute '__weakref__' of 'A' objects>,
    #  '__doc__': None,
    #  '__getattribute__': <slot wrapper '__getattribute__' of 'object' objects>
    # }

Did you notice that appart from the constructor __init__ everything is alien
in this dictionary? Where do they come from? Actually, in python as in java,
every class inherits from a single class: Object. This class defines methods
that every class should implement and attributes that every class should
have, such as __dict__ in python that gives the dictionary representation of
an object.

A point on the vocabulary
=========================

So, all we had so far were regular lists, functions, variables and
dictionaries. Where are all those magical class, objects, methods, attributes
and so on?

The fact is that those are not magical at all. An object is an abstract
concept ; it is the group of things that forms a coherent set. A specific set
of data in memory that implements an object is called an instance. A class
is the structural convention of how we represent a specific kind of object.
It is a map of how to build (instantiate) an object.

A function that is linked to an object is called a method. That's all. It is
a regular function (at least in our system) but it is useful to have a name
for that kind of functions, and method it is.

A function that acts on a class can be considered a method too. After all, it
is part of the family of functions that are bound to something. But as they
are effective on any object of the class we give them a special name: a class
method.

In the same way, a variable that is linked to an object is called an
attribute. One can access attributes directly, but in many languages like
java it means that you can't change how the object is implemented afterward.
That's why, in java or C++, one uses special functions to get or set
attributes. In python you have a system of properties: you can transparently
put a function in place of an attribute in order to change the inner
structure without breaking any code.

We didn't really talk about constructors and destructors. Those are the name
of the methods used to create or destroy an instance. In most language they
are called automatically, but that is just syntaxic sugar like most
"object-oriented features".

Ok, I'll admit that this section may be a little confusing, just remember
that everything is easy and that you can code it in a few lines, it will be
easier.

Conclusion
==========

There are many things to say about object systems and object oriented
programming. I won't explain here how to actually use an object system,
others have done it many times. But I think that it was worth the effort to
build an object system from scratch and see how those functionalities can be
made from simple tools and data structures.

Of course, many things can be added to this simplistic system, and it
actually is a fun exercise that I encourage you to do very much.

