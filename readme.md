### My .bashrc

Some say it is crazy to stick to Bash since better shells like zsh or fish
exist;some say it makes no sense to customize one's environment too much, since
setting them up is such a pain. Some say it is folly to hope getting the same
scripts to work in Linux and BSD environments. Some say the first thing to do
when setting up a Mac OS install is to replace the Bash 3 install with something
modern ('some' here including Apple themselves).

I rejected those assertions; instead, I chose something different; I chose the
impossible; I chose.. This.

The basic idea is to keep Bash for familiarity, while enabling some sweet
options, and changing the prompt to something less bloated.

I hear you ask: Olivier, how does that address the set-up pain? Simply, child:
this script is meant to be multi-environment and self-maintaining. Since we
only seek to sweeten the core Bash experience, it is no problem to only enable
the components actually available on the current machine. Installation is to be
kept as simple as possible: copy this script in one's home, and done. Additional
components and updates are a few mindless types away.