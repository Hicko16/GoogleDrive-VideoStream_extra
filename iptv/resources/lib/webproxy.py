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


class ThreadedWebGUIServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

class WebProxyServer(ThreadingMixIn,HTTPServer):

    def __init__(self, *args, **kw):
        HTTPServer.__init__(self, *args, **kw)
        self.ready = True



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


        # redirect url to output
        elif re.search(r'/twisted/', str(self.path)):
#            self.send_response(200)
#            self.end_headers()
            print "TWISTED" + "\n\n\n"
            count = 0
            results = re.search(r'/([^\/]+)/(.*)$', str(self.path))
            if results:
                domain = str(results.group(1))
                parameters = str(results.group(2))
            #self.send_response(200)
            #self.end_headers()
            #xbmcplugin.assignOutputBuffer(self.wfile)
            #cookies = self.headers['Cookie']

            req = urllib2.Request(domain + '/' + parameters,  None)
            print "proxy "+ domain + '/' + parameters + "\n"

            try:
                response = urllib2.urlopen(req)
            except urllib2.URLError, e:
                if e.code == 403 or e.code == 401:
                    print "STILL ERROR"+str(e.code)+"\n"
                    return
                else:
                    return

            self.send_response(200)

            print str(response.info()) + "\n"
            self.send_header('Content-Type',response.info().getheader('Content-Type'))
            #self.send_header('Content-Range', response.info().getheader('Content-Range'))
            self.send_header('Cache-Control',response.info().getheader('Cache-Control'))
            self.send_header('Date',response.info().getheader('Date'))
            #self.send_header('Content-type','video/mp4')
            #self.send_header('Accept-Ranges','bytes')

            self.end_headers()

            CHUNK = 16 * 1024
            while True:
                chunk = response.read(CHUNK)
                if not chunk:
                    break
                self.wfile.write(chunk)

            #response_data = response.read()
            response.close()
            return


        # redirect url to output
        else:
            # no options
            return