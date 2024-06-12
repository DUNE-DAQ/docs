# DUNE DAQ Software Developer Rules

Any software project consisting of multiple individuals will suffer if those individuals fail to communicate clearly with one another. A lack of communication can result in code reversions and ill-timed code merges, along with frustration and hurt feelings which can slow the progress of a project. To avoid this, the DUNE DAQ software project has rules about who to communicate with when you make different types of changes to the code. 

These different types of code change are described below, each with an
accompanying communication rule. They are presented in order of
increasing need for communication, with concrete examples given. Note
that code changes also require adherence to our [git versioning system
development
workflow](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/development_workflow_gitflow/),
though the focus here is on the human communication aspect of software
development.

Also be aware that while these rules apply for most of the development
cycle, they don't apply when we're in the one-to-two week official
release period before a frozen release is cut. During the release
period, we have just one rule, and it's simple: any planned change
needs to be announced to the project at our morning release meetings as well as on the `dunedaq-integration` Slack channel. 

## Minor documentation changes within a single package

You can make these on your own. Examples are limited to:

* Fixing typos in documentation

* Removing documentation you're sure is obsolete

## Changes within a single package which don't affect other code

These require you to have a second developer take a look at your
changes before they can be merged into `develop`. Examples include:

* Adding a feature to a package which users and developers wouldn't notice unless told about it

* Fixing an obvious bug (e.g. `if (string1 = string2) { ...`)

* Making simple changes to get non-conforming code to conform to [our styleguide](packages/styleguide/README.md)

* Bumping a version in a `CMakeLists.txt` file when you're about to add a new tag

## Changes within a single package which affect other code, in and/or outside of the package

This type of change needs to be mentioned to the maintainer(s) of the repository or repositories affected by the changes, including obviously the repository directly modified. To find the maintainer(s) if you're not sure who they are you can look [here](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/team_repos/). Examples of this kind of change are:

* Altering behavior in a function which other parts of the code rely on

* Refactoring large parts of the codebase after a code review

## Changes across many packages 

A change which is planned to be made across many repositories all at once needs to be brought to the attention not only of the maintainers of the repositories, but also to the project as a whole. This means the members of Software Coordination (John Freeman, `jcfree@fnal.gov` and Pengfei Ding, `dingpf@fnal.gov`) should be notified, and the planned change announced on the `dunedaq-integration` Slack channel. No examples are needed as this rule is self-explanatory. 

[Back to the DUNE DAQ software documentation homepage](README.md)
