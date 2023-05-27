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
import os
import sys

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.insert(0, os.path.abspath('../_packages/sphinx-extensions/current/src/sphinxcontrib'))

import dylan.domain
import dylan.themes as dylan_themes


# -- Project information -----------------------------------------------------

project = 'Dylan Package Docs'
copyright = '2023, Dylan Hackers'
author = 'Dylan Hackers'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'dylan.domain',
    'sphinx.ext.intersphinx'
]

# This makes it so that each document doesn't have to use
#   .. default-domain:: dylan
# but they probably should anyway, so that they can be built separately
# without depending on this top-level config file.
primary_domain = 'dylan'

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    '_build', 'Thumbs.db', '.DS_Store',
    # Submodules may cause docs to be duplicated because Sphinx automatically
    # finds all .rst files.
    '**/submodules', '**/ext',
    # Prevent "README.rst: WARNING: document isn't included in any toctree".
    '**/README.rst'
]


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = dylan_themes.get_html_theme_default()

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = dylan_themes.get_html_theme_options_default()

# Add any paths that contain custom themes here, relative to this directory.
html_theme_path = [dylan_themes.get_html_theme_path()]

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
#html_static_path = ['_static']

# intersphinx_mapping = {
#     'binary-data': ('https://opendylan.org/documentation', None),
#     'concurrency': ('https://opendylan.org/documentation', None),
# }
# intersphinx_mapping = {
#     'hacker': ('https://opendylan.org/documentation/hacker-guide/', None),
#     'http': ('https://opendylan.org/documentation/http/', None),
#     'testworks': ('https://opendylan.org/documentation/testworks/', None)
# }

