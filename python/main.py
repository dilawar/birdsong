""" Starting point of the program.

Last modified: Tue Dec 16, 2014  04:30PM

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

def main(config):
    g.config = config
    af = reader.AudioFile(config.get('audio', 'filepath'))
    af.readData()
    bs = birdsong.BirdSong(af.data)
    bs.processData(sample_size = 2*1e5)

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

    action.add_argument('--extract-notes', '-e'
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
            , type = argparse.FileType('r')
            , help = 'File where notes are stored and read from'
            )

    parser.add_argument('--config', '-c'
            , metavar='config file'
            , default = 'birdsongs.conf'
            , required = True
            , help = "Configuration file to fine tune the processing"
            )

    class Args: pass 
    args = Args()
    parser.parse_args(namespace=args)
    config = configParser(args.config)
    g.args_ = args

    config.add_section("audio")
    config.set("audio", "filepath", args.input_song)
    main(config)
