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

from threading import Lock, Thread
from SocketServer import ThreadingMixIn
import threading
import re
import urllib, urllib2
import sys


class ThreadedWebGUIServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

class WebProxyServer(ThreadingMixIn,HTTPServer):

    def __init__(self, *args, **kw):
        HTTPServer.__init__(self, *args, **kw)
        self.ready = True
        self.iptvMatrix = []
        self.lock = Lock()
        self.value = 0


    def setCredentials(self, iptvFile):
        print "set credentials "+str(iptvFile)+"\n"
        iptvFH = open(iptvFile,"r")
        for line in iptvFH:
            self.iptvMatrix.append(line.rstrip().split(','))

        iptvFH.close()

        for entry in self.iptvMatrix:
            print "entry " + str(entry[1])
            if entry[2] == "0":
                entry[2] = 0
            else:
                entry[2] = 1

    def getCredential(self):
        self.lock.acquire()

        for entry in self.iptvMatrix:
            print "testing" + str(entry[2]) + "x"
            if entry[2] == 0:
                entry[2] =1
                self.lock.release()

                return (entry[0],entry[1])

        self.lock.release()
        return (-1,0)
    def freeCredential(self, username):
        self.lock.acquire()
        for entry in self.iptvMatrix:
            print "testing" + str(username) + "vs" + str(entry[1])
            if entry[0] == username and entry[2] == 1:
                entry[2] =0
                print "releasing " + str(username)
                self.lock.release()
                return
        self.lock.release()




class webProxy(BaseHTTPRequestHandler):


    #Handler for the GET requests
    def do_POST(self):

        # debug - print headers in log
        headers = str(self.headers)
        print(headers)


        print "POST\n\n"

        # passed a kill signal?
        if self.path == '/kill':
#            self.server.ready = False
            return





    def do_HEAD(self):

        # debug - print headers in log
        headers = str(self.headers)
        print(headers)


        print "HEAD HEAD HEAD\n\n"

        # passed a kill signal?
        if self.path == '/kill':
#            self.server.ready = False
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
            if self.server.username is not None:
                self.wfile.write('<html><form action="/kill" method="post">Username: <input type="text" name="username"><br />Password: <input type="password" name="password"><br /><input type="submit" value="Stop Server"></form></html>')
            else:
                self.wfile.write('<html><form action="/kill" method="post"><input type="submit" value="Stop Server"></form></html>')

            #self.server.ready = False
            return
        elif re.search(r'/testlock/', str(self.path)):
            import time
            self.server.lock.acquire()
            print self.server.value
            time.sleep(20)
            self.server.value = self.server.value + 1
            self.server.lock.release()
            print self.server.value

        elif re.search(r'/test/', str(self.path)):
            print self.server.getCredential()

        elif re.search(r'/free/', str(self.path)):
            self.send_response(200)
            self.end_headers()
            count = 0
            results = re.search(r'/free/(.*)$', str(self.path))
            if results:
                username = str(results.group(1))
                self.server.freeCredential(username)


        # redirect url to output
        elif re.search(r'/twisted/', str(self.path)):
            print "TWISTED" + "\n\n\n"
            count = 0
            results = re.search(r'/twisted/(.*)$', str(self.path))
            if results:
                url = str(results.group(1))
            self.send_response(301)
            self.send_header('Location','http://' + str(url))
            self.end_headers()


            return


        # redirect url to output
        else:
            # no options
            return