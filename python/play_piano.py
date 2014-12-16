#!/usr/bin/env python

import sys
try:
    from mingus.midi import fluidsynth   
except:
    print("Install fluishsynth library and mingus on your system and try again")
    sys.exit(0)
import os 
import time

def playNotes(notes, xscale = 0.01):
    fluidsynth.init('/usr/share/sounds/sf2/FluidR3_GM.sf2',"alsa")
    currTime = 0
    for n in notes:
        waitTime = n.startx * xscale - currTime
        currTime = n.startx * xscale
        fluidsynth.play_Note(pow(n.energy, 0.2), 0, 100)
        print("Played %s, Waiting for %s " % (n, waitTime))
        time.sleep(waitTime)

    fluidsynth.stop_everything()

class Note:

    def __init(self):
        self.height = 0
        self.width = 0
        self.points = []
        self.energy = 0.0

    def __repr__(self):
        msg = "h{}, w{}, e{}".format(
                self.height
                , self.width
                , self.energy
                )
        return msg

def main(noteFile):
    notes = []
    with open(noteFile, "r") as nFile:
        for l in nFile:
            n = Note()
            fields=l.split(';')
            for f in fields:
                key, val = f.split("=")
                if key == "width":
                    n.width = int(float(val))
                elif key == "height":
                    n.height = int(float(val))
                elif key == "startx":
                    n.startx = int(float(val))
                elif key == "starty":
                    n.starty = int(float(val))
                elif key == "energy":
                    n.energy = float(val)
            notes.append(n)
    playNotes(notes)

if __name__ == '__main__':
    import sys
    import os
    noteFile = sys.argv[1]
    main(noteFile)
