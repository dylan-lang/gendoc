# This Makefile is for building the docs only. Use `dylan build` to build
# gendoc itself.

.PHONY: clean cleandocs docs gendoc

gendoc:
	dylan build gendoc

docs: gendoc
	_build/bin/gendoc -o output

clean:
	rm -rf _build _packages registry

cleandocs:
	rm -rf output/index.rst
	rm -rf output/package
	rm -rf output/_build
