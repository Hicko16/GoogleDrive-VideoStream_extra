'''
    Copyright (C) 2014-2017 ddurdle

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


'''


from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

from SocketServer import ThreadingMixIn
import threading
import re
import urllib, urllib2
import sys
import os


class ThreadedWebGUIServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

class FFMPEGServer(ThreadingMixIn,HTTPServer):

    def __init__(self, *args, **kw):
        HTTPServer.__init__(self, *args, **kw)
        self.ready = True

    def setFFMPEG(self, ffmpegCmd):
        self.ffmpegCmd = ffmpegCmd

    def setFFPROBE(self, ffmpegCmd):
        self.ffprobeCmd = ffmpegCmd


class ffmpegServer(BaseHTTPRequestHandler):


    #Handler for the GET requests
    def do_POST(self):

        # debug - print headers in log
        headers = str(self.headers)
        print(headers)

        if self.path == '/process':

            content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
            post_data = self.rfile.read(content_length) # <--- Gets the data itself
            self.send_response(200)
            self.end_headers()
            print "DUMP " + str(post_data) + "\n"

            for r in re.finditer('cmd\=(.*?)$' ,
                     post_data, re.DOTALL):
                cmd = r.group(1)
                for r in re.finditer('\-y \"?(.*?)/[^\/]+\"?$' ,
                         cmd, re.DOTALL):
                        path = r.group(1)

                        print "command = " + str(cmd) + "\n"
                        print "path = " + str(path) + "\n"
                        if not os.path.exists(path):
                            try:
                                os.makedirs(path)
                            except OSError as exc: # Guard against race condition
                                if exc.errno != errno.EEXIST:
                                    raise
                        os.system(str(self.server.ffmpegCmd) + ' ' + str(cmd))
            return
        elif re.search(r'/start/', str(self.path)):
            pid = re.search(r'/start/(\d+)', str(self.path)).group(1)
            content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
            post_data = self.rfile.read(content_length) # <--- Gets the data itself
            self.send_response(200)
            self.end_headers()
            print "DUMP " + str(post_data) + "\n"

            os.system('touch /tmp/' + str(pid)+'; </tmp/' + str(pid)+ ' ' + str(self.server.ffmpegCmd) + ' ' + str(post_data))
            return
        elif re.search(r'/ffprobe', str(self.path)):
            pid = re.search(r'/ffprobe/(\d+)', str(self.path)).group(1)
            content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
            post_data = self.rfile.read(content_length) # <--- Gets the data itself
            self.send_response(200)
            self.end_headers()
            print "DUMP " + str(post_data) + "\n"

            os.system(str(self.server.ffmpegCmd) + ' ' + str(post_data) + " 2> /tmp/"+ str(pid))
            if os.path.exists("/tmp/"+ str(pid)):
                fp = open("/tmp/"+ str(pid), "r")
                output = fp.read()
                fp.close()
                self.wfile.write(output)
            return
        elif re.search(r'/stop/', str(self.path)):
            pid = re.search(r'/stop/(\d+)', str(self.path)).group(1)
            self.send_response(200)
            self.end_headers()
            os.system("echo 'q' > /tmp/" + str(pid))

            return




    def do_HEAD(self):

        # debug - print headers in log
        headers = str(self.headers)
        print(headers)

        # passed a kill signal?
        if self.path == '/kill':
            return




    #Handler for the GET requests
    def do_GET(self):



        # debug - print headers in log
        headers = str(self.headers)
        print(headers)


        # passed a kill signal?
        if self.path == '/kill':
            self.send_response(200)
            self.end_headers()
            return


        # redirect url to output
        else:
            # no options
            return
