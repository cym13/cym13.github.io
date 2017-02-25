=============================
Comment who fonctionne-t-il ?
=============================

Explication préliminaire
========================

Une question posée sur irc est à l'origine de cette question, l'utilisateur
en question assurant que **who** ne retournait rien pour lui, pas même les
informations du shell courant.

Le cas a paru intéressant pour montrer comment utiliser strace en pratique.

Bon, ok, mais c'est quoi who ?
==============================

**who** est une commande permettant de voir quels sont les utilisateurs
loggés sur le système, sur quel terminal et depuis combien de temps.

Exemple:

.. code:: bash

      $ who
      cym13    tty1         2016-02-15 18:17
      cym13    pts/1        2016-02-15 19:08 (:pts/2:S.0)
      cym13    pts/3        2016-02-15 18:17 (:pts/4:S.0)
      cym13    pts/5        2016-02-15 18:17 (:pts/6:S.0)
      cym13    pts/7        2016-02-15 18:17 (:pts/8:S.0)
      cym13    pts/9        2016-02-15 20:23 (:pts/10:S.0)
      cym13    pts/12       2016-02-15 19:21 (:pts/13:S.0)
      cym13    pts/15       2016-02-15 19:50 (:pts/2:S.1)

Je suis loggé une fois sur le système depuis un tty d'où la première ligne,
et j'ai 7 terminaux d'ouverts. À chacun correspond un pts. Comme on peut le
constater il est difficile d'imaginer lancer **who** sans avoir de sortie, on
devrait avoir au moins une ligne correspondant au shell depuis lequel **who**
est lancé.

Du coup on va chercher à savoir comment fonctionne **who**. Et pour ça on va
lire son code source ! Bon peut-être pas en fait. **who** est un logiciel
libre faisant partie du projet GNU coreutils donc son code source est tout à
fait accessible. Cependant ça nous donnera des informations sur comment il
est sensé fonctionner en théorie alors que des informations dynamiques
(quelles sont effectivement les opérations effectuées) seraient
intéressantes. Ceci étant dit j'invite vraiment à prendre l'habitude de lire
le code de ce genre de programmes, c'est très instructif.

Bon, mais du coup on fait quoi ?
================================

Et bien du coup nous allons utiliser **strace**. **strace** est un utilitaire
permettant de tracer les appels systèmes fait au noyau linux.

Un appel quoi ?
---------------

Le travail du noyau linux c'est de faire le lien entre le matériel (clavier,
écran, souris, disque dur...) et le logiciel utilisant ce matériel. Un
logiciel n'accède donc normalement jamais au matériel directement, à la place
il dépose sa demande auprès du noyau qui lui interragit avec le matériel puis
renvois la réponse. Cette demande c'est un appel système.

On fait donc des appels systèmes tout le temps puisque chaque interraction
avec quelque chose qui n'est pas logiciel en génère ! Au moment où j'écris
ces lignes par exemple j'ai des appels systèmes read() qui sont effectués
pour lire les touches tapées au clavier, des appels write() pour sauvegarder
périodiquement mon fichier sur mon disque dur, des appels recv() sans doute
aussi en arrière plan avec mon lecteur de RSS qui reçoit des informations
depuis des servers distants... Toute action non triviale passe par un appel
système ou presque.

Pour savoir quels sont les appels systèmes pour linux 64 bits on peut aller
voir dans /usr/include/asm/unistd_64.h

.. code:: bash

    $ cat /usr/include/asm/unistd_64.h
    #ifndef _ASM_X86_UNISTD_64_H
    #define _ASM_X86_UNISTD_64_H 1

    #define __NR_read 0
    #define __NR_write 1
    #define __NR_open 2
    #define __NR_close 3
    #define __NR_stat 4
    #define __NR_fstat 5
    #define __NR_lstat 6
    ...

Comme on peut le voir les appels systèmes sont numérotés, on apperçoit read()
et write() que nous avons déjà évoqué.

Pour avoir plus d'information sur un appel système on peut utiliser le
manuel, les pages correspondants aux appels systèmes sont dans la section 2 :

.. code:: bash

    $ man 2 read
    READ(2)       Linux Programmer's Manual       READ(2)

    NAME
           read - read from a file descriptor

    SYNOPSIS
           #include <unistd.h>

           ssize_t read(int fd, void *buf, size_t count);

..  ***

On peut constater que du point de vu d'un programmeur un appel système est
une fonction C comme une autre, il est tout à fait possible de les utiliser
dans un programme directement.

Bon, mais strace du coup ?
==========================

**strace** nous permet de tracer ces appels pour un processus donné et donc
de voir ce qui est demandé exactement au kernel et ce qu'il répond en retour.

Voici un exemple sur une commande simple..

.. code:: bash

    $ strace echo 'Hello World!'
    execve("/usr/bin/echo", ["echo", "Hello World!"], [/* 47 vars */]) = 0
    brk(0)                                  = 0x23ac000
    access("/etc/ld.so.preload", R_OK) 
         = -1 ENOENT (No such file or directory)
    open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
    fstat(3, {st_mode=S_IFREG|0644, st_size=205301, ...}) = 0
    mmap(NULL, 205301, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fe7c7132000
    close(3)                                = 0
    open("/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
    read(3,
         "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\7\2\0\0\0\0\0"...,
         832) = 832
    fstat(3, {st_mode=S_IFREG|0755, st_size=1991416, ...}) = 0
    mmap(NULL, 4096, PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fe7c7131000
    mmap(NULL, 3815984, PROT_READ|PROT_EXEC,
        MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fe7c6ba0000
    mprotect(0x7fe7c6d3b000, 2093056, PROT_NONE) = 0
    mmap(0x7fe7c6f3a000, 24576, PROT_READ|PROT_WRITE,
         MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x19a000) = 0x7fe7c6f3a000
    mmap(0x7fe7c6f40000, 14896, PROT_READ|PROT_WRITE,
         MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fe7c6f40000
    close(3)                                = 0
    mmap(NULL, 4096, PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fe7c7130000
    mmap(NULL, 4096, PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fe7c712f000
    arch_prctl(ARCH_SET_FS, 0x7fe7c7130700) = 0
    mprotect(0x7fe7c6f3a000, 16384, PROT_READ) = 0
    mprotect(0x606000, 4096, PROT_READ)     = 0
    mprotect(0x7fe7c7165000, 4096, PROT_READ) = 0
    munmap(0x7fe7c7132000, 205301)          = 0
    brk(0)                                  = 0x23ac000
    brk(0x23cd000)                          = 0x23cd000
    open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
    fstat(3, {st_mode=S_IFREG|0644, st_size=1633792, ...}) = 0
    mmap(NULL, 1633792, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fe7c6fa0000
    close(3)                                = 0
    fstat(1, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0
    mmap(NULL, 4096, PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fe7c7164000
    write(1, "Hello World!\n", 13Hello World!
    )          = 13
    close(1)                                = 0
    munmap(0x7fe7c7164000, 4096)            = 0
    close(2)                                = 0
    exit_group(0)                           = ?
    +++ exited with 0 +++

.. ***

Bon. Vu comme ça ça ne parait pas particulièrement utile, et pourtant il y a
beaucoup d'informations très intéressantes. On va voir ça par partie pour
comprendre un peu mieux ce qui se passe. **L'essentiel est de ne pas chercher
à tout comprendre**. Il y a beaucoup de choses qui se passe et seule une
fraction correspond à notre problème. Il ne faut pas se focaliser sur
l'incompris.

La première ligne est un appel à exceve(). Cet appel dit au système
d'exploitation « Hé, je voudrais lancer le programme /usr/bin/echo avec les
arguments "echo" et "Hello World!". » Le fait d'avoir "echo" comme argument
ne devrait pas étonner les programmeurs, si vous avez déjà récupéré les
arguments passés par la ligne de commande dans un programme vous savez que le
premier argument est le nom avec lequel le programme a été appelé.

Ensuite le système charge d'éventuelles librairies passées via LD_PRELOAD, on
voit que l'accès a échoué car nous n'en avons pas spécifié. Si vous ne savez
pas ce qu'est LD_PRELOAD je vous invite à vous renseigner dessus ; bien que
ce soit hors du propos de cet article c'est un système très sympa à
connaître.

On charge ensuite la librairies standard C en ouvrant deux librairies et lisant
le contenu des fichiers avant de les refermer (d'open() à close()). Open
renvois un *file descriptor*, un identifiant du fichier ouvert. C'est ce *file
descriptor* qu'on passe en premier argument de read, on peut donc savoir
depuis quel fichier on lit les données. Il existe 3 descripteurs de fichiers
spéciaux:

    - 0 pour l'entrée standard, accessible seulement en lecture
    - 1 pour la sortie standard, accessible seulement en écriture
    - 2 pour la sortie d'erreur, accessible seulement en écriture

C'est aussi pour cette raison que lorsque l'on ouvre des fichiers les
descripteurs que l'on obtient commencent normalement à 3.

On peut aussi remarquer différents appels à mmap(). mmap() est une fonction
très utile permettant d'affecter un block de la mémoire matérielle à un
certaine addresse pour pouvoir interragir facilement avec sans reccourir au
système d'exploitation à chaque lecture ou écriture.

On remarque aussi quelques appels à fstat(). fstat() permet d'aquérir des
informations sur un fichier (droits d'accès, taille...). Lui aussi prend un
descripteur de fichier en argument.

La partie véritablement intéressante arrive à peine quelques lignes avant la
fin:

.. code:: C

    write(1, "Hello World!\n", 13Hello World!
    )          = 13

Voilà. On a écrit "Hello World!\n" sur la sortie standard. Tout ça pour ça.
Les lignes suivantes ne servent qu'à remballer. La raison pour laquelle cette
ligne semble cassée c'est qu'en fait les deux sorties (standard et erreur)
sont mélangées, mais on a bien deux lignes différentes en fait:


.. code:: C

    # stderr
    write(1, "Hello World!\n", 13)          = 13

    # stdout
    Hello World!

Bon. Voilà. On a vu un echo et on a eu un apperçu de ce que strace faisait.
Mais du coup, pour who?

Le cas de who
=============

Je ne vais pas détailler autant que pour echo car beaucoup d'étapes sont
redondantes. Comme on l'a vu l'essentiel est à la fin, donc je vais commencer
par là.

.. code:: C

    write(1, "cym13    tty1         2016-02-15"..., 405) = 405
    close(1)                                = 0

Ok, donc on écrit le texte sur la sortie standard. Super, mais ça on était
déjà au courant. Remontons de quelques lignes:

.. code:: C

    stat("/dev/pts/1", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/3", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 3), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/5", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 5), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/7", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 7), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/9", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 9), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/11", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 11), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0
    stat("/dev/pts/12", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 12), ...}) = 0
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2971, ...}) = 0

Ok, donc on récupère des informations sur différents fichiers dans /dev/pts
et /etc/localtime. Un petit **man 5 localtime** nous en dis plus sur ce
fichier et nous apprend qu'il pointe vers un fichier spécial correspondant à
la timezone de notre ordinateur. On cherche donc à récupérer des informations
temporelles, ça fait sens avec ce qu'on voit.

Les fichiers en /dev/pts font sens également: il est courant dans le monde
unix  de représenter les ressources systèmes par des fichiers et les numéros
correspondent à mes pts ouverts. On peut donc supposer qu'il vérifie s'ils
existent pour savoir si les pts correspondants existent vraiment et depuis
combien de temps.

Mais d'où tire-t-il la liste précise en premier lieu ? Je veux dire, il n'a
pas testé /dev/pts/2 par exemple, c'est donc qu'il savait déjà quoi chercher.
Comment ? Remontons encore...

On croise au passage le petit manquant de la liste: /dev/tty1:

.. code:: C

    stat("/dev/tty1", {st_mode=S_IFCHR|0600, st_rdev=makedev(4, 1), ...}) = 0
    open("/etc/localtime", O_RDONLY|O_CLOEXEC) = 3

Mais il faut remonter plus loin pour trouver ce que l'on cherche. On trouve
une série d'appels à read (entre autres choses) ressemblant à ça:

.. code:: C

    read(3, "\7\0\0\0\350l\0\0pts/12\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 384) = 384

On remarque au milieu de cette chaine de caractère (tronquée par strace pour
limiter le bruit) pts/12. Ce n'est sans doute pas une coïncidence. Toutes les
autres lignes ont également au milieu un pts/quelquechose. On dirait donc que
l'on lit des blocs de 384 octets dans un fichier binaire et que ce bloc
contient les informations sur notre pts. Un bloc binaire de taille fixe
contenant différentes informations ? En C ça serait une structure, il y a
sans doute plus d'informations dans ce bloc qu'il n'y semble. Mais dans quel
fichier sommes-nous en train de lire tout ça ?

Le *file descriptor* est 3, remontons jusqu'à un appel open() renvoyant 3:

.. code:: C

    open("/var/run/utmp", O_RDONLY|O_CLOEXEC) = 3

Nous sommes donc en train de lire dans /var/run/utmp. Que nous dit le manuel?

.. code:: bash

    $ man 5 utmp
    UTMP(5)                Linux Programmer's Manual               UTMP(5)

    NAME
           utmp, wtmp - login records

    SYNOPSIS
           #include <utmp.h>

    DESCRIPTION
       The utmp file allows one to discover information about who is currently
       using the system.  There may be more users currently using the  system,
       because not all programs use utmp logging.

Bien ! Donc ce fichier est un journal de qui est loggé et comment. On a
également un élément de réponse à notre mystère : si l'utilisateur n'est pas
loggé avec un système utilisant utmp alors il est possible que who ne le
trouve pas.

La question se pose donc de savoir si **who** lis d'autres fichiers ou non,
et lesquels. Facile, juste au-dessus du open() pour /var/run/utmp on trouve :

.. code:: C

    access("/var/run/utmpx", F_OK) = -1 ENOENT (No such file or directory)

C'est le seul appel de la sorte et donc le seul fichier non trouvé. Il reste
possible que who s'arrète simplement au premier fichier qu'il trouve sans
aller plus loin, mais ce n'est pas visible dans notre première expérience.

Et notre structure alors ?
--------------------------

Tout est là, dans le man de utmp :

.. code:: C

    struct utmp {
        short   ut_type;              /* Type of record */
        pid_t   ut_pid;               /* PID of login process */
        char    ut_line[UT_LINESIZE]; /* Device name of tty - "/dev/" */
        char    ut_id[4];             /* Terminal name suffix,
                                         or inittab(5) ID */
        char    ut_user[UT_NAMESIZE]; /* Username */
        char    ut_host[UT_HOSTSIZE]; /* Hostname for remote login, or
                                         kernel version for run-level
                                         messages */
        struct  exit_status ut_exit;  /* Exit status of a process
                                         marked as DEAD_PROCESS; not
                                         used by Linux init (1 */
        /* The ut_session and ut_tv fields must be the same size when
           compiled 32- and 64-bit.  This allows data files and shared
           memory to be shared between 32- and 64-bit applications. */
    #if __WORDSIZE == 64 && defined __WORDSIZE_COMPAT32
        int32_t ut_session;           /* Session ID (getsid(2)),
                                         used for windowing */
        struct {
            int32_t tv_sec;           /* Seconds */
            int32_t tv_usec;          /* Microseconds */
        } ut_tv;                      /* Time entry was made */
    #else
         long   ut_session;           /* Session ID */
         struct timeval ut_tv;        /* Time entry was made */
    #endif
 
        int32_t ut_addr_v6[4];        /* Internet address of remote
                                         host; IPv4 address uses
                                         just ut_addr_v6[0] */
        char __unused[20];            /* Reserved for future use */
    };

.. ***

Voilà, je pense que ça ira pour cette fois. On a pu voir que **strace** même
utilisé naïvement sans options aucunes peut être utilisé pour comprendre
comment les choses marchent et on en a profité pour apprendre les principes
fondamentaux derrière **who**. Strace est un outil très puissant qui a
beaucoup de possibilités, n'hésitez pas à en manger !
