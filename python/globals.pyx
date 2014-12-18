
"""global.py: Keep globals here

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

import logging
import time 
import datetime
import os

# create logger with 'spam_application'
logger = logging.getLogger('chidiya')
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
fh = logging.FileHandler('chidiya.log')
fh.setLevel(logging.DEBUG)

# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)

# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)

# @brief Configuration read from the file
config_ = None
args_ = None 

# Global debug level
verbosity_ = 0

sampling_freq = 0.0
xscale = 1.0
yscale = 1.0

# Timestamping
st = time.time()
stamp = datetime.datetime.fromtimestamp(st).strftime('%Y-%m-%d-%H')

basedir = "_output"

def createDataDirs(createTimeStampDir = True):
    if not os.path.isdir(basedir):
        os.makedirs(basedir)
    if createTimeStampDir:
        dirPath = os.path.join(basedir, stamp)
        if not os.path.isdir(dirPath): os.makedirs(dirPath)
        else: dirPath = basedir
    return dirPath
