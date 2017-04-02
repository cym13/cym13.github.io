#!/usr/bin/env python3

# This program simulates a bank with money transfers.
# Those transfers are encrypted but not authenticated.
#
# The goal is to demonstrate that it is possible to temper with the messages
# in order to hijack money transfers to our benefit.
#
# To test launch the program, then turn on the evil flag and restart.
# Stop with Ctrl-C to see each user's balance.

# Configuration
BE_EVIL    = False # Turn to True to start hacking the bank communications
USE_COLORS = True


# ANSI Colors!
GREEN   = '\x1b[32m'
RED     = '\x1b[31m'
YELLOW  = '\x1b[33m'
MAGENTA = '\x1b[35m'
RESET   = '\x1b[0m'

def log(color, text):
    if USE_COLORS:
        print("%s%s%s" % (color, text, RESET))
    else:
        print(text)

def log_bad(text):
    log(RED, text)

def log_good(text):
    log(GREEN, text)

def log_warning(text):
    log(YELLOW, text)

def log_special(text):
    log(MAGENTA, text)


class Bank:
    """
    Our bank. Nothing very complicated, just plain old money transfers
    between users.
    """
    def __init__(self):
        self.user_data = {
                "Alice":   10000,
                "Bob":     10000,
                "Charles": 10000,
                "Denis":   10000,
                "Eve":         0
            }

        self.msg_id = 0

    def secret_key(self):
        """
        We use a static key as that makes it easier to see the similarities
        between each message.
        For more fun, use a different key for each transaction!
        """
        return "S3cr3tK3y!"

    def transfer(self, msg):
        """
        We process the transfer. Three steps:
          1. Decipher the message
          2. Validate its data
          3. If it is valid, transfer the money

        Returns either the destination if the call was successfull so that we
        are able to compare it to the expected one, or None if something bad
        happened.
        """
        try:
            plaintext = decrypt(msg, self.secret_key())
            destination, origin, amount, msg_id = plaintext.split('|')
            amount = int(amount)
            msg_id = int(msg_id)

        except ValueError:
            log_bad("Error while decrypting %s" % msg)
            return

        if origin not in self.user_data:
            log_bad("[%s] User not found %s" % (msg_id, origin))
            return

        if destination not in self.user_data:
            log_bad("[%s] User not found %s" % (msg_id, destination))
            return

        if self.user_data[origin] < amount:
            log_bad("[%s] Not enough money!" % msg_id)
            return

        self.user_data[origin]      -= amount
        self.user_data[destination] += amount

        log_good("[%s] Transfered $%s from %s to %s" %
              (msg_id, amount, origin, destination))

        return destination

    def request(self, origin, destination, amount):
        """
        A transfer request. Let's imagine that it is sent over the network to
        justify encryption.
        """
        result = encrypt('%s|%s|%s|%s' %
                         (destination, origin, amount, self.msg_id),
                         self.secret_key())
        log_warning("[%s] Requesting a transfer of $%s from %s to %s" %
              (self.msg_id, amount, origin, destination))

        real_destination = self.transfer(proxy(result))

        if real_destination and real_destination != destination:
            log_special("HACKED!")

        self.msg_id += 1
        print()


def proxy(data):
    """
    This proxy allows us to simulate a Man-In-The-Middle attack: we receive
    the encrypted transfer request from the client, modifie it, then send it
    to the bank.
    """
    print(bytes.hex(data.encode('utf-8')))

    if not BE_EVIL:
        return data

    # Let's steal Bob's money!
    #
    # Well, we won't take the money he already has. Instead we will hijack
    # any transfer request to him in order to steal the money he's about to
    # gain.
    #
    # We know that our messages are of the form:
    #    destination|origin|amount|id
    #
    # We want to change the destination. To do that we will change the first
    # bytes. How many? Three, because coincidence (lol) Bob and Eve both have
    # three letters in their name.
    #
    # By XOR-ing "Bob" and "Eve" we get what you could call the "difference"
    # of the two. If we XOR this difference with the first three bytes of the
    # text we should find it in the deciphered text, effectively transforming
    # "Bob" into "Eve".

    diff = [ord(x[0]) ^ ord(x[1]) for x in zip("Bob", "Eve")]

    result = list(ord(x) for x in data)

    result[0] = result[0] ^ diff[0] # 'B' -> 'E'
    result[1] = result[1] ^ diff[1] # 'o' -> 'v'
    result[2] = result[2] ^ diff[2] # 'b' -> 'e'

    return ''.join(chr(x) for x in result)


def encrypt(data, key):
    """
    Our encryption function. Just good old RC4, so not secure but largely
    good enough for the tests. Keep in mind that we aren't attacking the
    cipher itself so it would work with others (although it may require some
    tweaking).
    """
    x = 0
    box = list(range(256))
    for i in list(range(256)):
        x = (x + box[i] + ord(key[i % len(key)])) % 256
        box[i], box[x] = box[x], box[i]
    x = 0
    y = 0
    out = []
    for char in data:
        x = (x + 1) % 256
        y = (y + box[x]) % 256
        box[x], box[y] = box[y], box[x]
        out.append(chr(ord(char) ^ box[(box[x] + box[y]) % 256]))

    return ''.join(out)

def decrypt(data, key):
    """ With RC4 encrypting and decrypting use the same function """
    return encrypt(data, key)


def main():
    import random
    import time

    bank = Bank()

    try:
        while True:
            # Eve is malicious, nobody wants to deal with her
            good_users = ("Alice", "Bob", "Charles", "Denis")
            origin = random.choice(good_users)

            # Make sure the destination isn't the origin
            destination = origin
            while destination == origin:
                destination = random.choice(good_users)

            amount = random.choice(range(bank.user_data[origin] + 1))

            if amount == 0:
                continue

            bank.request(origin, destination, amount)
            time.sleep(1)

    except KeyboardInterrupt:
        print("\n-----------")
        for user, amount in bank.user_data.items():
            print("%s\t$%s" % (user, amount))


if __name__ == "__main__":
    main()
