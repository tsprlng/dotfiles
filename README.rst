tsprlng's dotfiles
==================

This is a recent adventure I've undertaken to try and maintain a more consistently pleasant computing environment for myself between servers, as well as workstations and home laptops.

- `Home laptop <http://github.com/tsprlng/dotfiles/tree/homedir-marvin>`_
- `Generic server <http://github.com/tsprlng/dotfiles/tree/homedir-server>`_

My previous attempt to do something similar based on automatically templated-out files for different target machines was far too tedious to be practical in reality (especially after a whole day of Puppet misery) — I've gone back to using Git directly on my home directory (via a wrapper function in ``.zshrc`` to explicitly enable interaction with the separated ``GIT_DIR``).

With the requirement to use this specific command to interact with Git in the dotfiles/"``~``" context, the idea is not as accident-prone as it might seem at first, and in fact it's actually handy to be able to refer to the dotfiles repo while in the middle of working on another!

The disadvantage compared to using templates is that improvements must be specifically ported across environments by merging them between branches — although so far I'm seeing this as a pleasant educational experience. Actually the auto-resolution is normally pretty good about keeping intended differences after you go "each way once" manually preserving them. (See also: `How to merge a patch in from a different environment without getting all the deliberate differences as well`_.)

My enthusiasm is helped by the fact that this sort of tidying-up can be done at leisure, with the freedom to keep things in an unclean state as long as necessary for practicality or healthy laziness. It's also enjoyable having a consistent, basic task on which to keep the Git-abuse expertise sharp.


Motivation
----------

- After a long time of not giving much of a shit and just using the default bash/vim configs on production servers, I'm sick of them being clunky and am even willing to have intense arguments about installing zsh.

- In parallel with the specific wish for consistency, comes the need for efficiency in basic things — hence I've abandoned `(the ancient version of)`__ oh-my-zsh_ (on which I used to lazily rely) in favour of trying to have a single ``.zshrc`` file with only the stuff I actually use. (Obviously I'm quite lucky that all the relevant distributions of zsh come with quite similar and complete base completion configs...)

.. _oh-my-zsh: https://github.com/robbyrussell/oh-my-zsh
__ https://github.com/tsprlng/oh-my-zsh

- This led naturally to the decision to reconstruct everything from scratch on a new machine, importing one tiny improvement at a time. It's been fun! No regrets yet.


Bootstrapping
-------------

Bootstrapping is a bit manual, and still annoying in some respects. It involves downloading ``.dotfiles/setup.sh`` and running it with the branch name, at which point it checks out the repo properly and does a ``dotfiles reset``. This leaves things as they are, letting differences from the intended state show up, before a manual ``dotfiles reset --hard`` dumps the usual files into place.

What I'm currently doing about bootstrapping the config on servers is similar, but the download and checkout is done by an ``ssh_bootstrap`` function in the local ``.zshrc`` file which remotely triggers the same process via SSH. This is nasty, particularly since it requires the remote machine to pull directly from Github over the internet via HTTPS. I'll eventually come up with something better involving a direct ``git push``, but haven't cared enough yet, or lived with it for long enough to know what's best.


How to merge a patch in from a different environment without getting all the deliberate differences as well
-----------------------------------------------------------------------------------------------------------

There are obviously several ways of doing this, but what I usually do is:

- ``merge -s ours`` (Symbolically merge, but throw away all the differences in the other branch completely).

- Then, ``cherry-pick --no-commit`` the intended patch(es) into the index.

- Then, ``commit --amend`` the cherry-picked intentional differences into the original merge, finally creating a situation that looks about right.

This matches the sort of disgusting hacky way I normally use Git. It seems to be designed for that though.
