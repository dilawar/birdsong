"""note.py: Class representing a note.

Last modified: Fri Dec 19, 2014  01:13AM

"""
    
__author__           = "Dilawar Singh"
__copyright__        = "Copyright 2013, Dilawar Singh and NCBS Bangalore"
__credits__          = ["NCBS Bangalore"]
__license__          = "GNU GPL"
__version__          = "1.0.0"
__maintainer__       = "Dilawar Singh"
__email__            = "dilawars@ncbs.res.in"
__status__           = "Development"

import scipy
import numpy as np
import cv2
from lxml import etree
import globals as g

cdef class Note:

    cdef object origin, points, xpoints, ypoints, hull
    cdef double energy, width, height
    cdef int computed, geometryComputed
    cdef int startx, starty
    cdef double xscale

    property points:
        def __get__(self): return self.points
        def __set__(self, points): self.points = points

    property startx:
        def __get__(self): return self.startx 
        def __set__(self, val): self.startx = val

    property starty:
        def __get__(self): return self.starty
        def __set__(self, v): self.starty = v

    property width:
        def __get__(self): return self.width 
        def __set__(self, v): self.width = v

    property height:
        def __get__(self): return self.height
        def __set__(self, v): self.height = v

    property xscale:
        def __get__(self): return self.xscale 
        def __set__(self, v): self.xscale = v

    def __cinit__(self, x, y):
        self.origin = (x, y)
        self.energy = 0.0
        self.width = 0.0
        self.height = 0.0
        self.hull = None
        self.points = []
        self.xpoints = []
        self.ypoints = []
        self.computed = 0
        self.geometryComputed = 0
        self.startx = 0
        self.starty = 0
        self.xscale = 1.0

    cpdef computeAll(self, image):
        if self.computed == 0:
            self.computeGeometry()
            for p in self.points:
                self.energy += image[p[0], p[1]] 
            self.computed = 1

    cdef computeGeometry(self):
        if self.geometryComputed == 0:
            self.startx = min(self.xpoints)
            self.starty = min(self.ypoints)
            self.width = max(self.xpoints) - self.startx
            self.height = max(self.ypoints) - self.starty
            self.geometryComputed = 1

    def __repr__(self):
        msg = "start={},energy={},width={},height={}".format(
                self.origin
                , self.energy
                , self.width
                , self.height
                )
        return msg

    cpdef toElementTree(self, xml=True):
        if self.computed == 0:
            raise UserWarning("One or more parameter(s) of your note is not "
                    "computed. Please use self.computeAll(img) function at "
                    " appropriate place"
                    )
        # Else create a xml representation.
        noteExp = etree.Element("note")
        noteExp.set('xscale', "%s" % g.xscale)
        noteExp.set('yscale',"%s" % g.yscale)

        startxElem = etree.SubElement(noteExp, "startx")
        startxElem.text = "%s" % self.startx
        startyElem = etree.SubElement(noteExp, "starty")
        startyElem.text = "%s" % self.starty

        widthElem = etree.SubElement(noteExp, "width")
        widthElem.text = "%s" % self.width 

        heightElem = etree.SubElement(noteExp, "height")
        heightElem.text = "%s" % self.height

        energyElem = etree.SubElement(noteExp, "energy")
        energyElem.text = "%s" % self.energy

        pointsElem = etree.SubElement(noteExp, "points")
        for p in self.points:
            pElem = etree.SubElement(pointsElem, "point")
            xElem = etree.SubElement(pElem, "x")
            yElem = etree.SubElement(pElem, "y")
            xElem.text = "%s" % p[0]
            yElem.text = "%s" % p[1]

        return noteExp

    cpdef toXML(self):
        """Convert note to xml string """
        nXml = self.toElementTree()
        return etree.tostring(nXml, pretty_print=True)


    cpdef addPoint(self, point):
        assert point >= [0, 0], "Got %s " % point
        y, x = point
        self.xpoints.append(x)
        self.ypoints.append(y)
        self.points.append(point)

##
# @brief Plot the note. We need to change the index of points before using
# fillConvexPoly function.
#
# @param img Image onto which points needs to be plotted.
# @param kwargs
#
# @return None.

    cpdef plot(self, img):
        points = [[p[1], p[0]] for p in self.points]
        points = np.asarray(points)
        cv2.fillConvexPoly(img, points, 1)

    
    # This function is also called from python. Therefore cpdef instead of cdef.
    cpdef isValid(self):
        """Check if a given note is acceptable or note.
        """
        cdef int minPixelsInNote = int(g.config_.get('note', 'min_pixels'))
        cdef int minWidthOfNote = int(g.config_.get('note', 'min_width'))

        if len(self.points) < minPixelsInNote:
            g.logger.debug("Not enough points in this note. Rejecting")
            return False

        self.computeGeometry()
        if(self.width < minWidthOfNote):
            g.logger.info("Width of this note ({}) is not enough (< {})".format(
                self.width, minWidthOfNote)
                )
            return False
        return True

