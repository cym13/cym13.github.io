============================================================================
Les inodes, mais qu'est-ce que c'est ? Introduction  aux systèmes de fichier
============================================================================


Les chemins
===========

Un chemin vers un fichier c'est cool, ça permet de le désigner:

.. code:: sh

    /tmp/chat.png

ou de le manipuler:

.. code:: sh

    mv /tmp/chat.png /tmp/chaton.png

et ça à la manière d'un pointeur (le chemin n'est pas la donnée, il dit juste
où la trouver).

Mais quand on fait ce genre de trucs, on a pas envie de bouger le fichier
lui-même qui peut être très gros, on change juste le nom (chemin) du fichier.

Du coup on imagine d'abord un truc comme ça:

::

    +---------------------------+ |   +-------------------------+
    |  Espace Utilisateur       | |   |    /tmp/chat.png        |
    +---------------------------+ |   +-------------------------+
                                  |               |
                                  |               |
                                  |               v
    +---------------------------+ |   +-------------------------+
    |  Espace Disque            | |   |    Image sur disque     |
    +---------------------------+ |   +-------------------------+
                                  |

Le truc c'est que c'est assez limitant... Comment faire ça en réalité ? Un
chemin c'est adapté à un humain mais c'est pas super pratique pour un
ordinateur qui préfère les nombres, d'autant qu'un fichier peut être répartit
sur plusieurs emplacements et je ne parle même pas des liens...

De plus un chemin c'est juste un emplacement, hors tu sais qu'un pointeur
c'est bien mais que si on veut pouvoir travailler il faut d'autres
informations comme la taille, le type etc...

Bref c'est la merde.

Les inodes
==========

Le truc, c'est qu'un chemin c'est un identifiant humain pour un fichier mais
on a besoin d'un identifiant système.

Cet identifiant c'est l'inode.

En gros, le système de fichier entretiens une grosse table de correspondance
avec toutes les informations sur les fichiers. Sur des systèmes GNU/Linux on
peut les voir ces informations en faisant:

.. code:: sh

    stat /tmp/chat.png

Bon, c'est un petit abus de language de dire que l'inode c'est l'identifiant.
Dans la table de correspondance, on a des nœuds d'informations (information
node -> inode).  L'inode est donc le conteneur de l'ensemble des informations
liées à un fichier. Mais comme il a un numéro, et que c'est pratique de
manipuler un simple numéro, on appelle aussi inode cet identifiant.

Bref, c'est un identifiant qui permet de retrouver toutes les infos sur un
fichier.

Les liens s'organisent ensuite comme suit:

::

    +---------------------------+ |   +-------------------------+
    |  Espace Utilisateur       | |   |    /tmp/chat.png        |
    +---------------------------+ |   +-------------------------+
                                  |               |
                                  |               |  (1)
                                  |               v
    +---------------------------+ |   +-------------------------+
    |  Espace Système           | |   |   Inode de l'image      |
    +---------------------------+ |   +-------------------------+
                                  |               |
                                  |               |  (2)
                                  |               v
    +---------------------------+ |   +-------------------------+
    |  Espace Disque            | |   |    Image sur disque     |
    +---------------------------+ |   +-------------------------+
                                  |

Les liens physiques
===================


L'utilisateur n'a conscience que du lien n°1. Un lien chemin/inode est appelé
un lien physique. Il y en a au moins un par fichier. On les crée avec ln:


.. code:: sh

    ln /tmp/chat.png /tmp/chat_1.png

::

    +----------------------+       +-------------------------+
    |  /tmp/chat.png       |       |    /tmp/chat_1.png      |
    +----------------------+       +-------------------------+
                            `-.                |
         nouveau lien - - ->   \               |  (1)
                                \              v
    +----------------------+     `>+-------------------------+
    | Un inode anonyme...  |       |    Inode de l'image     |
    +----------------------+       +-------------------------+
                                               |
                                               |  (2)
                                               v
    +--------------------------------------------------------+
    | Disque                          |Image sur disque|     |
    +--------------------------------------------------------+

Lorque tu supprime un fichier par exemple, seul le chemin et le lien associé
est supprimé. Le lien inode/disque n'est supprimé que lorsque tout les liens
physiques ont été supprimé. L'image sur disque n'est jamais vraiment supprimée, 
l'espace disque correspondant est juste marqué comme pouvant acceuillir de
nouveaux fichiers qui viendront écraser les données existantes.


.. raw:: pdf

    PageBreak


Les liens symboliques
=====================

Il existe un autre type de lien plus souple : les liens symboliques.

.. code:: sh

    ln -s /tmp/chat.png /tmp/chat_1.png

::

    +----------------------+       +-------------------------+
    |  /tmp/chat.png       |------>|    /tmp/chat_1.png      |
    +----------------------+       +-------------------------+
               |                               |
               |                               |  (1)
               v                               v
    +----------------------+       +-------------------------+
    |   Inode lien         |       |    Inode de l'image     |
    +----------------------+       +-------------------------+
                   |                           |
                   |                           |  (2)
                   v                           v
    +--------------------------------------------------------+
    | Disque    | lien |              |Image sur disque|     |
    +--------------------------------------------------------+

Ce lien permet notamment de faire des liens entre systèmes de fichiers car
c'est un pointeur vers un chemin, il ne modifie pas l'inode du fichier
d'origine, mais comme c'est un fichier (un peu spécial certes) il a son
propre inode.

On peut noter par contre que si on supprime /tmp/chat_1.png alors le lien
symbolique est cassé et l'image sur le disque est marquée comme à supprimer.

De manière générale, il est recommendé d'utiliser des liens symboliques. Pour
être dans une situation dans laquelle on a *besoin* de faire un lien physique,
c'est que l'on sait déjà très bien ce que l'on fait car ce sont des
situations rares et souvent un peu délicates.

