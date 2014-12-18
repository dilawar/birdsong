"""algorithms.py: 

    All of my algorithms to detect pattern in image should be here.

Last modified: Mon Dec 15, 2014  05:47AM

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
import pylab
import cv2
import numpy as np
import note

cdef class Algorithms:

    cdef object image 

    def __cinit__(self):
        self.image = None

    ##
    # @brief Delete the rows. These rows do not contain any pixel darker (less than)
    # the threshold.
    #
    # @param image numpy matrix.
    # @param threshold threshold value of pixel.
    # @param kwargs
    #
    # @return  Image with deleted rows.
    cpdef autoCrop(self, image, threshold):
        """Delete rows which do not have any pixel less than the given value"""
        cdef int i
        rowsToDelete = []
        newImage = []
        for i, row in enumerate(image):
            if row.min() < threshold:
                newImage.append(row)
            else:
                # This row does not contain any signal. So screw it. 
                # NOTE: This works because it is almost guaranteed that you almost
                # always find continous block of such rows to remove and never
                # one or two rows in between.
                pass
        return np.array(newImage)
        
    ##
    # @brief Searches for a pixel which could be a candidate for searching a notes
    # in given image.
    #
    # @param image
    # @param pixelVal
    # @param kwargs
    #
    # @return 
    cdef searchForPixels(self, image, pixelVal):
        """Search for all pixels of a given value in image """
        cdef int i
        pixels = []
        for i, row in enumerate(image):
            for j, v in enumerate(row):
                if v == pixelVal:
                    pixels.append((i,j))
        assert len(pixels) > 0, "There must be at least one pixel of value %s" % pixelVal
        return pixels

    cdef findNotes(self, threshold = None):
        """Find notes in the given image """
        notes = []
        g.logger.info("Find notes in the image")
        # 1. Find the lowest pixel (darkest one) x.
        # 2. Use slithrine algorithm to get the note.
        # 3. Delete the note from the figure (make all pixel equal to 255).
        # 4. Go to step 1.
        minPixel = self.image.min()
        fracOfAvg = float(g.config_.get('note', 'maxval_pixal')) 
        maxvalOfStartPixel = fracOfAvg * self.image.mean()
        threshold = float(g.config_.get('note', 'boundary_threshold')) * maxvalOfStartPixel
        g.logger.debug("++ Slither start point {}, threshold {}".format(
            maxvalOfStartPixel
            , threshold)
            )

        while minPixel < maxvalOfStartPixel:
            minPixel = self.image.min()
            startPixels = self.searchForPixels(self.image, minPixel)
            while startPixels:
                x, y = startPixels.pop()
                if self.image[x, y] == minPixel:
                    note = self.slither(x, y, minPixel, threshold)
                    if note is not None:
                        g.logger.info("Found a note: %s" % note)
                        notes.append(note)
                else:
                    g.logger.debug("This starting pixel is already part of some note")
        return notes

    ##
    # @brief Main algorithm to detect the note.
    #
    # @param x x pos in image.
    # @param y y post in image.
    # @param image
    #
    # @return 
    cdef slither(self, startx, starty, startValue, threshold):
        assert startValue == self.image.min(), "Min in image can't be smaller than startValue"
        assert threshold > startValue, "Threshold should be larger than startval"
        n = note.Note(startx, starty)
        points = []
        points.append([startx, starty])
        while points:
            x, y = points.pop()
            self.image[x, y] = 255
            if x == 0 or y == 0: break
            # Make sure we never go beyound the row - 1 and column - 1 index.
            if x + 1 < self.image.shape[0] and y + 1 < self.image.shape[1]:
                n.addPoint([x,y])
                for a in [x-1, x, x+1]:
                    for b in [y-1, y, y+1]:
                        if self.image[a, b] < threshold:
                            points.append([a, b])
                            self.image[a, b] = 255
                            n.addPoint([a, b])
        if n.isValid():
            return n
        return None
        
    ##
    # @brief Find points which belongs to different edges.
    #
    # @param data Image matrix.
    #
    # @return 
    def notes(self, image):
        g.logger.info("Find points on the image which belongs to edges")
        # By now we have removed all the rows which do not have any interesting
        # pixels. This has reduced our search size. Now in this matrix, we need to
        # locate islands which belongs to notes. The islands must be separated by
        # some no which we do not know.
        self.image = image
        assert self.image.max() <= 256, "All pixels must be 0-255"
        notes = self.findNotes()
        return notes

