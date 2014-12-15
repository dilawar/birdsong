"""birdsong.py: 

    Process the data in birdsong.

Last modified: Tue Dec 16, 2014  01:34AM

"""
    
__author__           = "Dilawar Singh"
__copyright__        = "Copyright 2013, Dilawar Singh and NCBS Bangalore"
__credits__          = ["NCBS Bangalore"]
__license__          = "GNU GPL"
__version__          = "1.0.0"
__maintainer__       = "Dilawar Singh"
__email__            = "dilawars@ncbs.res.in"
__status__           = "Development"

import globals as g
import logging
import dsp 
import cv2
import scipy
import numpy as np
import pylab
import algorithms

import os
import sys

class BirdSong:

    #cdef object data, imageMat,  image, croppedImage, notesImage
    #cdef object Pxx, frequencies, bins
    #cdef object imageH, notes
    #cdef char* filename

    def __init__(self, data):
        self.data = data
        self.imageMat = None
        self.frequencies = None
        self.image = None
        self.croppedImage = None
        self.notesImage = None
        self.imageH = None
        self.filename = "spectogram.png"
        self.notes = []
        self.time = 0.0
        self.start_time = 0.0
        self.start_index = 0
        self.length = 0
        self.algo = algorithms.Algorithms()
        self.isCropped = int(g.config.get('global', 'autocrop'))

        # This calculate the baseline of note. Any note which is way to below it
        # (higher) is ignored. 
        self.baseline = 0

    def filterAndSort(self):
        """Filter notes and then sort all of them
        """
        # This sorting is done according to y position. Lower the startx
        # position better chance of it being a note.
        if self.isCropped:
            g.logger.info("Image was cropped before processing." 
                " Not doing the base-line test"
                )
            self.notes = sorted(self.notes, key=lambda note: note.startx)
            return 

        self.notes = sorted(self.notes, key=lambda note: note.starty)
        validNotes = []
        for i, n in enumerate(self.notes):
            assert self.baseline >= 0, "Expecting > 0, got %s" % self.baseline
            self.baseline = int(((self.baseline * i) + n.starty) / (i+1))
            if n.starty > 1.1 * self.baseline:
                g.logger.info("[REJECTED] %s ." % n 
                        + " Way too down from baseline. " 
                        + " baseline is %s " % self.baseline  
                        + " note is at %s " % n.starty
                        )

            else:
                validNotes.append(n)
        self.notes = sorted(validNotes[:], key = lambda note : note.startx)


    def updateBaseline(self, index, note):
        """Update the base line.
        If the given note is below baseline (1.1 factor) then return False,
        else return True.
        """
        totalNotes = len(self.notes)
        self.baseline = (self.baseline * totalNotes + note.starty) / (totalNotes + 1)
        if note.starty > 1.1 * self.baseline:
            g.logger.info("++ Very much away for the baseline: {} ~ {}".format(
                note.starty, self.baseline)
                )
            return False
        else:
            #print("++ Note index {} should be inserted".format(index))
            return True


    def processData(self, **kwargs):
        g.logger.info("STEP: Processing the speech data")
        self.time = float(g.config.get('global', 'time'))

        self.start_time = float(g.config.get('global', 'start_time'))
        self.start_index = int(self.start_time * g.sampling_freq)

        if self.time <= 0.0:
            stop = -1
        else:
            stop = self.start_index + int(self.time * g.sampling_freq)

        data = self.data[self.start_index:stop]
        g.logger.info("|- Processing index %s to %s" % (self.start_index, stop))
        #data = dsp.filterData(data, g.sampling_freq)
        self.Pxx, self.frequencies, self.bins, self.imageH = dsp.spectogram(
                data
                , g.sampling_freq
                , output = None
                )
        self.imageMat = self.imageH.get_array()
        # TODO: We should not save the png file rather work directory on numpy
        # array.
        g.logger.debug("+ Saving spectogram to %s " % self.filename)
        pylab.imsave(self.filename, self.imageMat)
        pylab.close()
        self.getNotes()
        #self.plotNotes("notes.png")
        self.plotNotes(filename = None)

    def getNotes(self, **kwargs):
        g.logger.info("Read image in GRAYSCALE mode to detect edges")
        self.image = cv2.imread(self.filename, 0)
        assert self.image.max() <= 256, "Expecting 256, got %s" % self.image.max()

        if int(g.config.get('global', 'autocrop')) != 0:
            raise Exception("Developer error: Dont' crop")
            g.logger.warn("++ Autocropping image")
            threshold = self.image.max() * float(g.config.get('global', 'crop_threshold'))
            self.croppedImage = self.algo.autoCrop(self.image, threshold)
        else:
            self.croppedImage = self.image
        img = np.copy(self.croppedImage)
        self.averagePixalVal = img.mean()
        g.logger.debug("+ Average pixal value is %s " % self.averagePixalVal)
        # Get all the notes in image and insert them into self.notes . Make sure
        # it is sorted.
        self.notes = self.algo.notes(img)
        assert len(self.notes) > 0, "There must be non-zero notes"
        self.filterAndSort()
        assert len(self.notes) > 0, "There must be non-zero notes"
        self.findSongs()

    def findSongs(self):
        """Find songs in collection of notes.
        """
        g.logger.debug("+ Finding songs in recording ... ")
        start = []
        for n in self.notes:
            start.append(n.startx)
        #pylab.plot(start, range(len(start)), '*')
        #pylab.show()
        print start


    def plotNotes(self, filename = None):
        # Plot the notes.
        fig = pylab.figure()
        ax1 = fig.add_subplot(211)
        ax2 = fig.add_subplot(212)
        self.notesImage = np.empty(shape=self.croppedImage.shape, dtype=np.int8)
        titleText = [ "{}:{}".format(va[0], va[1]) for va in (g.config.items('note'))]
        ax1.set_title(" ".join(titleText))
        ax1.set_label("Sampling freq {}".format(g.sampling_freq))
        self.notesImage.fill(255)
        for note in self.notes:
            note.plot(self.notesImage)
        ax2.imshow(self.croppedImage)
        ax1.imshow(self.notesImage, cmap=pylab.gray())
        if not filename:
            pylab.show()
        else:
            dirPath = g.createDataDirs()
            filename = os.path.join(dirPath, filename)
            g.logger.info("Saving notes and image to %s" % filename)
            pylab.savefig(filename)
