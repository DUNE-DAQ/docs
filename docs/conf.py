# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'DUNE DAQ Software'
# copyright = '2021, Alessandro Thea'
# author = 'Alessandro Thea'

# The full version, including alpha/beta/rc tags
release = 'v0.0.1'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_book_theme'

html_title = ""
html_theme_options = {
    "path_to_docs": "docs",
    "repository_url": "https://gitlab.cern.ch/hog/Hog",
    # "repository_branch": "gh-pages",  # For testing
    # "use_edit_page_button": True,
    "use_issues_button": True,
    "use_repository_button": True,
    "expand_sections": ["reference/index"]
    # For testing
    # "home_page_in_toc": True,
    # "single_page": True
    # "extra_footer": "<a href='https://google.com'>Test</a>",
    # "extra_navbar": "<a href='https://google.com'>Test</a>",
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

myst_enable_extensions = [
    "dollarmath",
    "amsmath",
    "deflist",
    "html_image",
    "colon_fence",
    "smartquotes",
    "replacements",
    "substitution",
]
myst_url_schemes = ("http", "https", "mailto")
myst_heading_anchors = 5
panels_add_boostrap_css = False
