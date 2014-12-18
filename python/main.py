""" Starting point of the program.

Last modified: Thu Dec 18, 2014  08:58PM

"""
    
__author__           = "Dilawar Singh"
__copyright__        = "Copyright 2013, Dilawar Singh and NCBS Bangalore"
__credits__          = ["NCBS Bangalore"]
__license__          = "GNU GPL"
__version__          = "1.0.0"
__maintainer__       = "Dilawar Singh"
__email__            = "dilawars@ncbs.res.in"
__status__           = "Development"

import birdsong
import globals as g
import reader 
import birdsong
import pyhelper.print_utils as pu
import process_notes

def main(config):

    # Read audio data.
    af = reader.AudioFile(config.get('audio', 'filepath'))
    af.readData()

    if g.args_.extract_notes:
        pu.dump("STEP", "Extracting notes ...")
        # Cool, now do the thingy on birdsong.
        bs = birdsong.BirdSong(af.data)
        bs.extractNotes()

    elif g.args_.process_notes:
        pu.dump("STEP", "Processing notes to form songs ...")
        pn = process_notes.ProcessNotes()
        pn.analyze()

def configParser(file):
    try:
        import ConfigParser as cfg
    except:
        import configparser as cfg

    config = cfg.ConfigParser()
    config.read(file)
    return config

if __name__ == '__main__':
    import argparse
    # Argument parser.
    description = '''Process bird songs'''
    parser = argparse.ArgumentParser(description=description)
    
    # Add mutually exclusive options
    action = parser.add_mutually_exclusive_group(required=True)

    parser.add_argument('--input_song', '-in'
            , required = True
            , help = 'Recorded song (aiff format)'
            )

    action.add_argument('--extract_notes', '-e'
            , action = 'store_true'
            , help = 'Input song file in aifc format to extract notes.'
            )


    action.add_argument("--process_notes", "-pn"
            , required = False
            , action = 'store_true'
            , help = "Process notes stored in this file"
            )

    parser.add_argument('--note_file', '-nf'
            , required = False
            , default = 'notes.dat'
            , help = 'File where notes are stored and read from'
            )

    parser.add_argument('--config', '-c'
            , metavar='config file'
            , default = 'chidiya.conf'
            , required = True
            , help = "Configuration file to fine tune the processing"
            )

    parser.add_argument('--verbose', '-v'
            , default = 0
            , help = "Verbosity level. Default 0"
            )

    class Args: pass 
    args = Args()
    parser.parse_args(namespace=args)
    g.args_ = args
    g.config_ = configParser(args.config)

    # Save these config variables to global module.
    g.config_.add_section("audio")
    g.config_.set("audio", "filepath", args.input_song)
    main(g.config_)
