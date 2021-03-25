
# Editing the documentation for a specific package

One of the main purposes of the official DUNE DAQ documentation is to
provide info about each package for its users. The webpages for each
package are generated off [Markdown
files](https://www.markdownguide.org/basic-syntax/) which need to be 
located in a `docs/` subdirectory in that package's repo. The one file
which must exist is `docs/README.md`; this serves as the homepage for
the package's documentation. It may provide links to other Markdown
files, or to other webpages, where necessary. Note that in this model,
it's possible to edit the documentation within a package's GitHub
page, making it easy to check for Markdown syntax errors before
committing. 

A few points need to be made:

- The documentation should be directed to a package's users, not
  its developers. Documentation for a package's developers (e.g., instructions
  on how to run its integration tests) should be located in the
  package's GitHub wiki

- The documentation on a given branch should match up with the code on
  the branch. 

- A corollary of this previous point is that if the code on a feature
  branch will alter the package in a way the user needs to be aware
  of, the documentation on the feature branch needs to be altered
  accordingly, and part of the review process for the merge into
  develop should be to ensure the new documentation is correct.

- Many packages will have wiki pages which already (Mar-25-2021)
  contain user-facing content. This content should be moved out of the
  wiki pages and into `docs/`. It's possible to grab the Markdown file corresponding to a GitHub wiki page with the command `curl -O https://raw.githubusercontent.com/wiki/DUNE-DAQ/<name of the  package>/<title of the wiki page with spaces replaced by hyphens>.md`

- Any `README.md` files in the base of a repo should be moved into a
  `docs/` subdirectory of the repo

