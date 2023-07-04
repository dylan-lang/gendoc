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
    'sphinx.ext.graphviz',
    'sphinx.ext.intersphinx',
    'sphinxcontrib.plantuml',
]

plantuml = 'java -jar /usr/share/plantuml/plantuml.jar'

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

html_theme = 'furo'             # https://pradyunsg.me/furo/customisation/
html_theme_options = {
    'sidebar_hide_name': True,
    'light_logo': 'images/opendylan-light.png',
    'dark_logo': 'images/opendylan-dark.png',

    # https://pradyunsg.me/furo/customisation/edit-button/
    'source_repository': 'https://github.com/dylan-lang/website',
    'source_branch': 'master',
    'source_directory': 'source/',
}
