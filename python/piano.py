"""piano.py: Play given notes on piano

Last modified: Sat Jan 18, 2014  05:01PM

"""
    
__author__           = "Dilawar Singh"
__copyright__        = "Copyright 2013, Dilawar Singh and NCBS Bangalore"
__credits__          = ["NCBS Bangalore"]
__license__          = "GNU GPL"
__version__          = "1.0.0"
__maintainer__       = "Dilawar Singh"
__email__            = "dilawars@ncbs.res.in"
__status__           = "Development"

import sys
try:
    from mingus.midi import fluidsynth   
    fluidsynth.init('/usr/share/sounds/sf2/FluidR3_GM.sf2',"alsa")
except:
    print("Install fluishsynth library and mingus on your system and try again")
    sys.exit(0)


import os 
import time

def playNotes(notes, xscale = 0.01):
    currTime = 0
    for n in notes:
        waitTime = n.startx * xscale - currTime
        currTime = n.startx * xscale
        fluidsynth.play_Note(n.height, 1, 127)
        print("Played %s " % n)
        #print("Waiting for %s " % waitTime)
        time.sleep(waitTime)

    fluidsynth.stop_everything()

