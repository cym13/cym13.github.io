===========================
Fixing video noise with sox
===========================

The issue
=========

This is not a security related post for once (although sox has many security
related uses). I just wanted to have a look at some defcon video_
but there was this annoying noise. I figured others may be interested in how
to fix it quick and dirty style and without reaching to the mouse.

.. _video: https://www.youtube.com/watch?v=KrOReHwjCKI

We'll use youtube-dl, sox and mpv there, nothing fancy.

Get the audio
=============

First of all we need to get the audio from the video. This is straitforward:

.. code:: shell

    youtube-dl --extract-audio    \
               --audio-format wav \
               "https://www.youtube.com/watch?v=KrOReHwjCKI"

In the following the audio file will be named *audio.wav*.


Fix the audio
=============

We can clearly hear the noise when listening to that audio, but at which
frequency is it exactly? Let's start with a spectrogram to see the sound:

.. code:: shell

    sox audio.wav -n spectrogram

.. image:: ../image/spectrogram_noisy.png

The big purple area is our noise. We want to remove as much as we can of it
but without removing the voice. The red band at about 4kHz stands out, it is
likely to be part of the "real" sound so we'll try cutting at 5kHz.

We want to low frequencies to pass so we need a lowpass filter. This lowpass
filter won't remove it blindly, but the higher the frequency the quieter the
sound will be. As for any sound manipulation sox is the solution:

.. code:: shell

    sox audio.wav fixed_audio.wav lowpass 5k

If you give the audio a try it sounds pretty well. Unfortunately sound isn't
really a good blog media so let's compare them visually by drawing another
spectrogram:

.. code:: shell

    sox fixed_audio.wav -n spectrogram

.. image:: ../image/spectrogram_fixed.png

We can see the noise was well reduced. If that's not enough there are sox
options to apply stronger filters but this will do in our case.

Playing the audio alongside the video
=====================================

Okay, great, but how do we play our video with the new sound? Turns out mpv
has an option for that:

.. code:: shell

    mpv --audio-file=fixed_audio.wav \
        "https://www.youtube.com/watch?v=KrOReHwjCKI"

Conclusion
==========

Sox is a great tool that doesn't get nearly as much credit as it should.
Whenever you want to do sound manipulations, analysis, visualization, it is
the tool I reach for.

This helps in some CTF challenges because hiding images_ in sound is fun, it
also helps for signal analysis. On that last subject I strongly recommend the
wonderful blog http://www.windytan.com/ which doesn't write enough. Really,
everything in there is of great value.

.. _images: http://amazingstuff.co.uk/technology/hidden-images-in-sound-recordings/

Although I hope this post will avoid me all this RTFMing next time I have
this problem. Turns out the words "audio" and "file" are pretty common in
mpv's manual.
