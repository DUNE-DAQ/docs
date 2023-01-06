# Developer Rules

Any software project consisting of multiple individuals will suffer if those individuals fail to communicate clearly with one another. A lack of communication can result in code reversions and ill-timed code merges, along with frustration and hurt feelings which can slow the progress of a project. To avoid this, the DUNE DAQ software project has a couple of rules about who to communicate with when code is changed. 

The use cases below are presented in order of increasing need for
communication. Note that these cases also require adherence to our
[git versioning system development
workflow](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/development_workflow_gitflow/),
though the focus here is on the human communication aspect of software
development.

## Very minor, obvious changes within a single package

You can make these on your own. There are only a few examples of this:
* Fixing typos in documentation
* Removing documentation you're sure is obsolete

## Changes within a single package which don't alter interfaces

These require you to have a second developer take a look at your
changes before it can be merged into `develop`. Examples include:
* Adding a feature to a package which users and developers wouldn't notice unless told about it
* Fixing an obvious bug (e.g. `if (string1 = string2) { ...`)
* Making simple changes to get non-conforming code to conform to [our styleguide] (packages/styleguide/README.md)
* Bumping a version in a `CMakeLists.txt` file when you're about to add a new tag

## Changes within a single package which unavoidably affect other developers/users

This type of change needs to be mentioned to the maintainer(s) of the repository in which the changes are being made. To find the maintainer(s) if you're not sure who they are you can look [here](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/team_repos/), though if you're at a point where you're making major changes within a package you probably already should know who they are. Examples of this kind of change are:
* Altering behavior in a function or function(s) which other parts of the code rely on
* Refactoring large parts of the codebase after a code review

## Changes across many packages 

A change which is made across many packages all at once needs to be brought to the attention not only of the mantainer(s) of the relevant repos, but also to at least one member of Software Coordination (John Freeman, `jcfree@fnal.gov` and Pengfei Ding, `dingpf@fnal.gov`). [WHAT ELSE?] No examples are needed as this rule is self-explanatory. 

[Back to the DUNE DAQ software documentation homepage](README.md)
