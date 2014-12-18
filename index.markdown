---
layout: page
title: Home
comments: true
repository_url: http://github.com/dilawar/birdsong
---

This cython application __chidiya__ (चिड़िया) -- Hindustani for bird -- is a work in
progress. It claims to do the following:

- Read recorded bird-songs (`aiff` file format). 
- Extract `notes` and store them in XML file.
- Process stored notes in an XML file and cluster them according to temporal
  variation. It calls them song.


## How to use the program 

Since it is a cython program, you need to build the application using `setup.py`
file.

    $ python setup.py build_ext --inplace

This should compile the cython files. The entry point of chidiya is `main.py`
file. You will get a detailed description if you execute the following:

    $ python main.py --help


