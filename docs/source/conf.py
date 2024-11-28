# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Dylan Package Documentation'
copyright = '2024, Dylan Hackers'
author = 'Dylan Hackers'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import os
import sys
sys.path.insert(0, os.path.abspath('../../_packages/sphinx-extensions/current/src/sphinxcontrib'))
extensions = [
    'dylan.domain',
    'sphinx.ext.graphviz',
    'sphinx.ext.intersphinx',
    'sphinx_copybutton',
]
primary_domain = 'dylan'
exclude_patterns = [
    '**/README.*',
]
show_authors = True
templates_path = ['_templates']


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'furo'             # https://pradyunsg.me/furo/customisation/

# Without this Furo adds the word "documentation" to the project name.
html_title = project
