###############################################################################
# Makefile for literate Haskell programes. It creates pdf and dvi documents as
# well as generate codes for execution,
#
# USAGE : make <target> file=<filename>
# <fileaname> must be without any extension. For example, if one wants to make
# example.snw for generating a dvi file then one should use following command.
# $ make dvi file=example
#
# (c) Dilawar, 2011
# Email : dilawar@ee.iitb.ac.in
# 
# June 30, 2011
###############################################################################
SHELL = /bin/sh
NOTANGLE = notangle 
NOWEAVE = noweave # it implies -n option. Automatic latex wrapper will not be includeded in out tex file.
PYC = python
APP = chidiya
SRCS = birdsong.snw main.snw
PYX = $(SRCS:.snw=.pyx)
TEX = $(SRCS:.snw=.tex)

$(APP) : $(SRCS)
	$(NOTANGLE) $(SRCS) > src/$(APP).pyx
	cd src && ./run.sh
	echo "Done"

dvi : $(TEX)
	echo "Creating tex files"
	latex -output-directory=docs ./docs/$@
	rm -rf *.log *.aux *.tex~

%.tex: %.snw
	$(NOWEAVE)  -delay $< > ./docs/$@

pdf : $(TEX)
	cd docs && latexmk 
