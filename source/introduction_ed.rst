======================
Ed: l'éditeur standard
======================

Introduction
============

Ed est un éditeur de texte datant de 1969, aujourd'hui encore, fait partie du
standard POSIX normalement respecté par tout système UNIX ou Linux. A
l'époque il n'était pas possible à cause des ressources limitées d'afficher
les modifications effectuées sur le texte en temps réel comme n'importe quel
éditeur récent le fait. On interragit avec le texte par commandes
interposées.

Ed est à l'origine de nombreux outils comme sed, ex, vi, ou vim qui reprennent
tout ou partie de ses commandes appréciées pour leur expressivité et leur
concision. Étant donné que ces outils sont maintenant communs cette
introduction suppose une certaine familiarité du lecteur avec au moins vi ou
sed bien qu'il soit possible de la suivre sans avoir utilisé ces outils
auparavant.

À la rencontre du monstre
=========================

Lançons la bête puis essayons de la quitter :

.. code:: text

    $ ed
    ^C
    ?
    quit
    ?
    q

Par défaut Ed ne possède aucun prompt permettant de distinguer l'attente
d'une commande d'une attente de texte "brut". De même l'affichage des erreurs
est succint : un point d'interrogation marque l'incompréhension. La commande
'h' permet d'afficher des informations sur la dernière erreur rencontrée:

.. code:: text

    $ ed
    quit
    ?
    h
    Invalid command suffix
    q

Comme on peut le voir Ed n'a pas compris la commande "quit", mais semble
reconnaître le début. C'est tout à fait normal car 'q' est la commande
permettant de quitter l'éditeur. Toutes les commandes vous l'aurez deviné ne
sont constituées que d'une seule lettre.

Afin de faciliter l'édition nous allons définir un alias pour mettre en place
un prompt et automatiquement afficher les messages d'erreur :

.. code:: sh

    alias ed='ed --prompt=">>> " --verbose '

Tout les exemples du reste de cette introduction employeront cet alias.

.. raw:: pdf

    PageBreak

Édition basique
===============

Créer un nouveau fichier
------------------------

Nous allons maintenant créer un nouveau fichier pour explorer les
possibilités :

.. code:: text

    $ ed myfile
    myfile: No such file or directory
    >>> # La commande # permet de faire des commentaires dans ed

Entrons du texte avec 'a' pour 'append'.

.. code:: text

    >>> a
    Note the consistent user interface and error reportage.
    Ed is generous enough to flag errors,
    yet prudent enough not to overwhelm the novice with verbosity.
    .

Toute entrée de texte se termine par un point solitaire. Après cette edition
nous sommes placés à la fin du texte entré comme on peut facilement le
constater avec la commande 'p' pour 'print' ou encore 'n' pour 'number' qui
affichent respectivement la ligne courante et la ligne avec son numéro.

.. code:: text

    >>> p
    yet prudent enough not to overwhelm the novice with verbosity.
    >>> n
    3       yet prudent enough not to overwhelm the novice with verbosity.

On peut afficher une ligne en particulier en plaçant son numéro devant la
commande, et même employer une plage de nombre pour un affichage multiple :

.. code:: text

    >>> 2p
    Ed is generous enough to flag errors,
    >>> 1,3n
    1       Note the consistent user interface and error reportage.
    2       Ed is generous enough to flag errors,
    3       yet prudent enough not to overwhelm the novice with verbosity.

Il est possible d'utiliser ces addresses avec n'importe quelle commande Ed,
par exemple 'i' pour 'insert' qui a un effet similaire à 'a' si ce n'est que
le texte est entré avant la ligne courante au lieu de après.

.. code:: text

    >>> 1i
    # Source https://www.gnu.org/fun/jokes/ed.msg
    .

Entrer une addresse sans commande nous place à cette position.

.. code:: text

    >>> 2
    Note the consistent user interface and error reportage.

.. raw:: pdf

    PageBreak

Nous pouvons maintenant écrire le fichier sur le disque (write donc 'w') et
quitter ('q') l'éditeur. L'opération est suffisamment commune pour qu'on
puisse utiliser les deux commandes en une :

.. code:: text

    >>> wq
    203

Le nombre inscrit en sortie correspond au nombre d'octets écrits dans le
fichier. Write peut également prendre en argument un nom de fichier pour
enregistrer tout ou partie (avec une plage d'addresse) du fichier courant
dans un autre.

Éditer un fichier existant
--------------------------

Nous allons maintenant le reprendre, Ed nous placera naturellement à la
dernière ligne.

.. code:: text

    $ ed myfile
    203
    >>> p
    yet prudent enough not to overwhelm the novice with verbosity.

On retrouve l'affichage de la taille du fichier. Afficher tout le fichier est
possible à l'aide d'une range, '$' signifiant dans ce contexte « dernière
ligne ».

.. code:: text

    >>> 1,$p
    # Source https://www.gnu.org/fun/jokes/ed.msg
    Note the consistent user interface and error reportage.
    Ed is generous enough to flag errors,
    yet prudent enough not to overwhelm the novice with verbosity.

Cependant cela peut poser problème si le fichier que nous sommes en train de
manipuler est particulièrement gros. Ouvrons à fin d'exemple le fichier
/etc/services à l'aide de la commande 'e' pour 'edit' :

.. code:: text

    >>> e /etc/services
    293694

Nous allons afficher le texte bloc par bloc depuis le début en utilisant '.'
pour référencer la ligne courante.

.. code:: text

    >>> 1
    # Full data: /usr/share/iana-etc/port-numbers.iana
    >>> .,.+5p
    # Full data: /usr/share/iana-etc/port-numbers.iana

    tcpmux              1/tcp
    tcpmux              1/udp
    compressnet         2/tcp
    compressnet         2/udp
    >>> .,.+5p
    compressnet         2/tcp
    compressnet         3/udp
    rje                 5/tcp
    rje                 5/udp
    echo                7/tcp

On voit vite plusieurs problèmes avec cette méthode :

- Comme la ligne courante est comprise il faudrait en fait faire .+1,.+5p

- Le fait que Ed n'ai pas d'historique des commandes rend l'opération vite
  lassante.

C'est en partie pour ces raisons qu'Ed permet d'afficher le texte bloc par
bloc où chaque bloc fait la taille de l'écran courant avec 'z'.

.. code:: text

    >>> 1z
    # Full data: /usr/share/iana-etc/port-numbers.iana

    tcpmux              1/tcp
    tcpmux              1/udp
    compressnet         2/tcp
    compressnet         2/udp
    compressnet         3/tcp
    compressnet         3/udp
    rje                 5/tcp
    rje                 5/udp
    echo                7/tcp
    echo                7/udp
    discard             9/tcp
    discard             9/udp
    discard             9/sctp
    discard             9/dccp
    systat             11/tcp
    systat             11/udp
    daytime            13/tcp

Celui-ci peut même être combiné avec 'n' pour obtenir les numéros de lignes,
et sans addresse explicite il part de la ligne courante ce qui rend la
navigation plus aisée et sans répétition de ligne.

.. code:: text

    >>> zn
    20      daytime            13/udp
    21      qotd               17/tcp
    22      qotd               17/udp
    23      chargen            19/tcp
    24      chargen            19/udp
    25      ftp-data           20/tcp
    26      ftp-data           20/udp
    27      ftp-data           20/sctp
    28      ftp                21/tcp
    29      ftp                21/udp
    30      ftp                21/sctp
    31      ssh                22/tcp
    32      ssh                22/udp
    33      ssh                22/sctp
    34      telnet             23/tcp
    35      telnet             23/udp
    36      smtp               25/tcp
    37      smtp               25/udp
    38      nsw-fe             27/tcp

.. raw:: pdf

    PageBreak

Chercher et modifier
--------------------

Chercher du texte est sans suprise pour un utilisateur de vim :

- '/regex/' ammène à la première occurence rencontrée dans le sens de lecture
  naturel.

- '?regex?' ammène à la première occurence rencontrée dans le sens de lecture
  inverse.

- '/' ou '?' répètent la dernière recherche dans un sens ou dans l'autre.

- Il n'est pas nécessaire de "fermer" la recherche en répétant la commande si
  on ne combine pas celle-ci avec autre chose.

.. code:: text

    >>> /https/
    https             443/tcp
    >>> ?ssh?
    ssh                22/sctp
    >>> /https
    https             443/tcp
    >>> /
    https             443/udp
    >>> ?
    https             443/tcp

Comme suggérer on peut en effet l'employer en conjonction avec d'autres
commandes car une recherche par regex est en fait considéré comme une
addresse. On peut donc également les utiliser dans des ranges :

.. code:: text

    >>> 1
    # Full data: /usr/share/iana-etc/port-numbers.iana
    >>> /ssh/n
    31      ssh                22/tcp
    >>> /ssh/,/ssh/+5p
    ssh                22/tcp
    ssh                22/udp
    ssh                22/sctp
    telnet             23/tcp
    telnet             23/udp
    smtp               25/tcp

Pour réaliser une opération sur toutes les lignes correspondant à la
recherche on peut utiliser le préfix 'g' pour 'global'. C'est d'ailleurs de
là que vient le nom de grep : « g/re/p »

.. code:: text

    >>> g/ssh/p
    ssh                22/tcp
    ssh                22/udp
    ssh                22/sctp
    sshell            614/tcp
    sshell            614/udp
    netconf-ssh       830/tcp
    netconf-ssh       830/udp
    sdo-ssh          3897/tcp
    sdo-ssh          3897/udp
    netconf-ch-ssh   4334/tcp
    snmpssh          5161/tcp
    snmpssh-trap     5162/tcp
    tl1-ssh          6252/tcp
    tl1-ssh          6252/udp
    ssh-mgmt        17235/tcp
    ssh-mgmt        17235/udp

Pour réaliser une commande sur les lignes ne correspondant pas à une regex on
utilise le préfixe 'v' à la place de 'g' qui a notamment donné son nom à
l'option de grep '-v'.

Modifier le texte se fait principalement par l'intermédiare de deux
commandes : 's' pour 'substitute' et 'c' pour 'change'. La première modifie
une ou plusieurs lignes en remplaçant une expression par une autre alors que
la seconde supprime la ou les lignes addressées et entre en mode insertion
afin d'entrer la nouvelle version.

Substitute ne change cependant que la première occurence par défaut. On peut
lui adjoindre le suffixe 'g' pour signifier toutes les occurences ou en
suffixe un nombre pour signifier l'occurence précise à remplacer. De plus,
ommettre le symbole de fin de commande indique la volonté d'afficher le
nouveau texte :

.. code:: text

    >>> 1
    # Full data: /usr/share/iana-etc/port-numbers.iana
    >>> s/a/A/
    >>> p
    # Full dAta: /usr/share/iana-etc/port-numbers.iana
    >>> s/a/A
    # Full dAtA: /usr/share/iana-etc/port-numbers.iana
    >>> s/a/A/2
    >>> p
    # Full dAtA: /usr/share/iAna-etc/port-numbers.iana
    >>> s/a/A/2p
    # Full dAtA: /usr/share/iAnA-etc/port-numbers.iana
    >>> s/a/A/g
    >>> p
    # Full dAtA: /usr/shAre/iAnA-etc/port-numbers.iAnA
    >>> s/A/a/gp
    # Full data: /usr/share/iana-etc/port-numbers.iana

Pour substituer sur l'ensemble du texte on peut soit utiliser la range '1,$'
soit le préfixe '%' qui a le même effet. On est placé à la dernière occurence
modifiée.

.. code:: text

    >>> 1,$s/a/A/gp
    mAtAhAri        49000/tcp
    >>> %s/A/a/gp
    matahari        49000/tcp

On peut annuler la denrière modification avec 'u' pour 'undo'. Refaire 'u'
annule l'annulation ce qui revient à appliquer de nouveau la modification.

.. code:: text

    >>> u
    >>> p
    >>> p
    mAtAhAri        49000/tcp
    >>> u
    >>> p
    matahari        49000/tcp

.. raw:: pdf

    PageBreak

Supprimer une ligne se fait avec 'd' pour 'delete'.

.. code:: text

    >>> 1,5n
    1       # Full data: /usr/share/iana-etc/port-numbers.iana
    2
    3       tcpmux              1/tcp
    4       tcpmux              1/udp
    5       compressnet         2/tcp
    >>> 3d
    >>> 1,5n
    1       # Full data: /usr/share/iana-etc/port-numbers.iana
    2
    3       tcpmux              1/udp
    4       compressnet         2/tcp
    5       compressnet         2/udp
    >>> u
    >>> 1,5n
    1       # Full data: /usr/share/iana-etc/port-numbers.iana
    2
    3       tcpmux              1/tcp
    4       tcpmux              1/udp
    5       compressnet         2/tcp

Pour supprimer et insérer on peut utiliser 'c' :

.. code:: text

    >>> 3,4c
    haha
    huhu
    .
    >>> 1,5n
    1       # Full data: /usr/share/iana-etc/port-numbers.iana
    2
    3       haha
    4       huhu
    5       compressnet         2/tcp

Puisque nous n'avons pas les droits d'écriture dans le fichier il nous faut
quitter sans enregistrer, c'est fait avec 'Q'.

.. code:: text

    >>> w
    /etc/services: Permission denied
    ?
    Cannot open output file
    >>> q
    ?
    Warning: buffer modified
    >>> Q

Ce qui a été vu jusqu'ici suffit à une utilisation des plus basiques mais il
y a plus à Ed que cela et le confort dépend beaucoup des petites choses qui
facilitent la vie sans forcément la changer.

.. raw:: pdf

    PageBreak

Utilisation avancée
===================

Interagir avec le shell
-----------------------

Les interactions avec le shell sont sans doute le point le plus important du
confort dans l'utilisation de Ed. Elle se fait avec la commande '!' et permet
soit d'exécuter une commande shell, soit d'en récupérer le contenu dans le
document courant, soit de passer tout ou partie du document courant comme
entrée standard d'une commande.

.. code:: text

    $ ed
    >>> !ls
    articles  bin  Documents  downloads  images  myfile  usr  videos
    !
    >>> r !ls
    58
    >>> 1zn
    1       articles
    2       bin
    3       Documents
    4       downloads
    5       images
    6       myfile
    7       usr
    8       videos
    >>> 2,5w !grep o
    Documents
    downloads
    31
    >>> w !tr 'A-Z' 'a-z'
    articles
    bin
    documents
    downloads
    images
    myfile
    usr
    videos
    58
    >>> q

On a ici utilisé la commande 'r' pour 'read' que l'on avait pas eu l'occasion
de croiser auparavant. Elle permet d'insérer à la position courante le
contenu d'un autre fichier ou, comme ici avec '!', d'une commande shell.

.. raw:: pdf

    PageBreak

Insérer du texte au début d'un bloc
-----------------------------------

Moins une fonctionnalité avancées qu'un « truc » utile pour, par exemple
commenter ou identer du texte:

.. code:: text

    $ ed
    >>> a
    My best pony is Pinkie Pie
    Although I like Twilight very much
    And Rainbow Dash is just the coolest
    .
    >>> 1,3s/^/# /
    >>> 1,3p
    # My best pony is Pinkie Pie
    # Although I like Twilight very much
    # And Rainbow Dash is just the coolest


Déplacer et copier
------------------

Déplacer un bloc se fait avec 'm' pour 'move' et copier se fait avec 't' pour
'transfer'. Le bloc est plaçé après la ligne à l'addresse indiquée, celle-ci
pouvant être 0.

.. code:: text

    $ ed myfile
    203
    >>> 1zn
    1       # Source https://www.gnu.org/fun/jokes/ed.msg
    2       Note the consistent user interface and error reportage.
    3       Ed is generous enough to flag errors,
    4       yet prudent enough not to overwhelm the novice with verbosity.
    >>> 1,2m3
    >>> 1zn
    1       Ed is generous enough to flag errors,
    2       # Source https://www.gnu.org/fun/jokes/ed.msg
    3       Note the consistent user interface and error reportage.
    4       yet prudent enough not to overwhelm the novice with verbosity.
    >>> 2,3t0
    >>> 1zn
    1       # Source https://www.gnu.org/fun/jokes/ed.msg
    2       Note the consistent user interface and error reportage.
    3       Ed is generous enough to flag errors,
    4       # Source https://www.gnu.org/fun/jokes/ed.msg
    5       Note the consistent user interface and error reportage.
    6       yet prudent enough not to overwhelm the novice with verbosity.

Copier peut également se faire avec 'y' pour 'yank' et 'x'. Yank place la
cible dans le buffer de copie et 'x' place le contenu du buffer de copie à
l'addresse indiquée. Yank n'est pas la seule commande à modifier ce buffer :
lorsque l'on supprime avec 'd' ou change avec 'c' une ou plusieurs lignes
elles sont également placées dans ce buffer ce qui permet de faire du
« couper/coller ».

.. code:: text

    >>> 3y
    >>> 5x
    >>> 1zn
    1       # Source https://www.gnu.org/fun/jokes/ed.msg
    2       Note the consistent user interface and error reportage.
    3       Ed is generous enough to flag errors,
    4       # Source https://www.gnu.org/fun/jokes/ed.msg
    5       Note the consistent user interface and error reportage.
    6       Ed is generous enough to flag errors,
    7       yet prudent enough not to overwhelm the novice with verbosity.
    >>> 7d
    >>> 3x
    >>> 1zn
    1       # Source https://www.gnu.org/fun/jokes/ed.msg
    2       Note the consistent user interface and error reportage.
    3       Ed is generous enough to flag errors,
    4       yet prudent enough not to overwhelm the novice with verbosity.
    5       # Source https://www.gnu.org/fun/jokes/ed.msg
    6       Note the consistent user interface and error reportage.
    7       Ed is generous enough to flag errors,


Ressources externes
===================

Cheat Sheet
    http://www.catonmat.net/download/ed.text.editor.cheat.sheet.pdf

Tutorial par le vénérale Brian Kernighan (co-créateur d'unix et du C)
    http://www.verticalsysadmin.com/vi/a_tutorial_introduction_to_the_unix_text_editor.pdf
