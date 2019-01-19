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
import os.path
import time
import requests



class ThreadedWebGUIServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

class WebProxyServer(ThreadingMixIn,HTTPServer):

    def __init__(self, *args, **kw):
        HTTPServer.__init__(self, *args, **kw)
        self.ready = True
        self.iptvMatrix = []
        self.sessions = {}
        self.lock = Lock()
        self.value = 0

    def setServer(self, serverURL, key, manual):
        self.serverURL = serverURL
        self.key = key
        self.manual = manual


    def checkRunnings(self):
        self.lock.acquire()
        sessionsToDelete = []
        for session in self.sessions:
            #hasn't been modified in over a min
            if not os.path.exists(os.path.join(self.transcodetmp, session)) or time.time() - os.stat(os.path.join(self.transcodetmp, session)).st_mtime > 70:
                print "release session " + session + " username " + self.sessions[session] + "\n"
                if os.path.exists(os.path.join(self.transcodetmp, session)):
                    print " time.time " + str(time.time() - os.stat(os.path.join(self.transcodetmp, session)).st_mtime) + "\n"
                response = urllib2.urlopen(self.serverURL + '/free/' + self.sessions[session] + '/' + session)
                sessionsToDelete.append(session)
        for session in sessionsToDelete:
            try:
                del self.sessions[session]
            except KeyError:
                pass
        self.lock.release()


class webProxy(BaseHTTPRequestHandler):


    #Handler for the GET requests
    def do_POST(self):

        # debug - print headers in log
        headers = str(self.headers)
        print(headers)


        print "POST\n\n"

        # passed a kill signal?
        if self.path == '/create':
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

        if len (self.server.sessions) > 0:
            self.server.checkRunnings()


        # passed a kill signal?

        if re.search(r'/testlock/', str(self.path)):
            import time
            self.server.lock.acquire()
            print self.server.value
            time.sleep(20)
            self.server.value = self.server.value + 1
            self.server.lock.release()
            print self.server.value


        elif re.search(r'/create', str(self.path)):
            self.send_response(200)
            self.end_headers()
            results = re.search(r'username=([^\=]+)$', str(self.path))
            if results:
                username = str(results.group(1))
                username = username.replace("%40", "@")
                username = username.replace("%20", " ")
                response = urllib2.urlopen('https://www.dinopass.com/password/simple')
                password = response.read()

                request = urllib2.Request(self.server.serverURL + '/emby/Users/New?api_key=' + self.server.key, "{\"Name\":\""+str(username)+"\"}",{'Content-Type': 'application/json'})
                response = urllib2.urlopen(request)
                data = response.read()
                results = re.search(r'\"Id\":\"([^\"]+)\"', data)
                if results:
                    ID = str(results.group(1))
                    request = urllib2.Request(self.server.serverURL + '/emby/Users/'+str(ID)+'/Policy?api_key=' + self.server.key, "{\"IsAdministrator\":false,\"IsHidden\":true,\"IsDisabled\":false,\"EnableLiveTvManagement\":false,\"EnableLiveTvAccess\":true,\"EnableMediaPlayback\":true,\"EnableAudioPlaybackTranscoding\":true,\"EnableVideoPlaybackTranscoding\":true,\"EnablePlaybackRemuxing\":true,\"EnableContentDeletion\":false,\"EnableContentDownloading\":false,\"EnableSyncTranscoding\":false,\"EnableMediaConversion\":false,\"RemoteClientBitrateLimit\":0}",{'Content-Type': 'application/json'})
                    response = urllib2.urlopen(request)
                    request = urllib2.Request(self.server.serverURL + '/emby/Users/'+str(ID)+'/Password?api_key=' + self.server.key, "{\"Id\":\""+str(username)+"\",\"CurrentPassword\":\"\",\"CurrentPw\":\"\",\"NewPw\":\""+str(password)+"\"}",{'Content-Type': 'application/json'})
                    response = urllib2.urlopen(request)
                    try:
                        response = urllib2.urlopen(self.server.serverURL + '/emby/Users/'+str(ID)+'/Connect/Link?ConnectUsername='+str(username)+'&api_key=' + self.server.key, data='')
                        self.wfile.write('ID created and linked to connect ID.  Manual login details are: ' + str(self.server.manual) + ', username = ' + str(username) + ', password = ' + str(password))
                    except:
                        self.wfile.write('Local (manual) ID created but linking to connect ID failed.  Manual login details are: ' + str(self.server.manual) + ', username = ' + str(username) + ', password = ' + str(password))

                else:
                    self.wfile.write('ID could not be created.')






        else:
            self.send_response(200)
            self.end_headers()
            self.wfile.write('<html><form action="/create" method="GET"><div><label for="username">Emby Connect ID:</label><input type="text" id="username" name="username"> </div><div class="button"><button type="submit">Submit</button></div></form></html>')
            return


