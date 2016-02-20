#!/usr/bin/env python
# encoding: utf-8
"""
untitled.py

Created by soh_la on 2012-08-01.
Copyright (c) 2012 soh_la. All rights reserved.


use it like this 

python batchConvertMovies.py --f session1

where --f is a dir of .mov file you want to convert

"""

import sys
import os
import getopt

from subprocess import call



help_message = '''
The help message goes here.
'''

class Usage(Exception):
	def __init__(self, msg):
		self.msg = msg


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST:
            pass
        else: raise	



def init():
	return


	

def main(argv=None):
	if argv is None:
		argv = sys.argv
	try:
		try:
			opts, args = getopt.getopt(argv[1:], "hqdl:v:", ["help", "folder="])
		except getopt.error, msg:
			raise Usage(msg)

		# option processing
		for option, value in opts:
			if option == "-v":
				verbose = True
			if option in ("-h", "--help"):
				raise Usage(help_message)
			if option in ("-f", "--folder"):
				s_folder = value

		files = os.listdir(s_folder)
			
		for i in range(0,len(files)):
			path = s_folder + '/' + files[i]
			newFileTitle = s_folder + '/' + os.path.splitext(files[i])[0] + "_converted.m4a"

			if path.endswith('.wav'):
				print >>sys.stderr, path + " : " + newFileTitle
				try:
					
					retcode = call(["ffmpeg","-i",path,"-strict","-2","-b:a","256k",newFileTitle])
					
					if (retcode < 0):
						print >>sys.stderr, "Terminated by signal", -retcode
					elif (retcode > 0):
						print >>sys.stderr, "Failed : ", retcode
						os.remove(newFileTitle)
			
				except OSError, e:
				    print >>sys.stderr, "Execution failed:", e			



			
	except Usage, err:
		print >> sys.stderr, sys.argv[0].split("/")[-1] + ": " + str(err.msg)
		print >> sys.stderr, "\t for help use --help"
		return 2


if __name__ == "__main__":
	init()
	sys.exit(main())
