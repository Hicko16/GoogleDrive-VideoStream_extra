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



class ThreadedWebGUIServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

class WebProxyServer(ThreadingMixIn,HTTPServer):

    def __init__(self, *args, **kw):
        HTTPServer.__init__(self, *args, **kw)
        self.ready = True
        self.iptvMatrix = []
        self.servers = {}
        self.sessions = {}
        self.lock = Lock()
        self.value = 0

    def setServer(self, serverURL, transcodetmp):
        self.serverURL = serverURL
        self.transcodetmp = transcodetmp


    def setCredentials(self, iptvFile):
        print "set credentials "+str(iptvFile)+"\n"
        iptvFH = open(iptvFile,"r")
        for line in iptvFH:
            self.iptvMatrix.append(line.rstrip().split(',') + [0])

        iptvFH.close()

        for entry in self.iptvMatrix:
            print "entry " + str(entry[1]) + '  ' + str(entry[2])

    def setServers(self, serverFile):
        print "set servers "+str(serverFile)+"\n"
        serverFH = open(serverFile,"r")
        for line in serverFH:
            entry = [line,0]
            self.servers[line] = 0

        serverFH.close()

        for entry in self.servers.keys():
            print "entry " + str(entry)

    def getCredential(self, session, IP):
        self.lock.acquire()

        if self.servers[IP] == 0:
            self.servers[IP] = session
        else:
            for server in self.servers:
                if self.servers[server] == 0:
                   self.servers[server] = session
                   IP = server
                   break

        for entry in self.iptvMatrix:
            print "testing" + str(entry[0]) + "-"+str(entry[1]) + "-"+str(entry[2]) +"\n"
            if entry[2] == 0:
                entry[2] =session
                self.lock.release()
                return (entry[0],entry[1],IP)

        self.lock.release()
        return (-1,0,0)


    def getStats(self):
        freeConnections = 0
        usedConnections = 0
        for entry in self.iptvMatrix:
            print "testing" + str(entry[2]) + "x"
            if entry[2] == 0:
                freeConnections = freeConnections + 1
            else:
                usedConnections = usedConnections + 1

        if freeConnections > 0:
            return "[OK] free = " + str(freeConnections) + ', used = ' + str(usedConnections) + "\n"
        else:
            return "[ALERT] free = " + str(freeConnections) + ', used = ' + str(usedConnections) + "\n"


    def freeCredential(self, username, session):
        self.lock.acquire()
        for server in self.servers:
            if self.servers[server] == session:
               self.servers[server] = 0
               break

        for entry in self.iptvMatrix:
            print "testing" + str(username) + "vs" + str(entry[1])
            if entry[0] == username and entry[2] == session:
                entry[2] =0
                print "releasing " + str(username)
                self.lock.release()
                return
        self.lock.release()


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

        elif re.search(r'/get/', str(self.path)):
            reqIPaddress = self.client_address[0]

            results = re.search(r'/get/([^\/]+)$', str(self.path))
            if results:
                session = str(results.group(1))
            results = re.search(r'/get/([^\/]+)/([^\/]+)$', str(self.path))
            if results:
                session = str(results.group(2))
                channel = str(results.group(1))
            userInfo = self.server.getCredential(session, reqIPaddress)
            self.send_response(200)
            self.end_headers()
            ip = userInfo[2]
            if ip == reqIPaddress:
                ip = '127.0.0.1'
            print "username = " + str(userInfo[0])  + " password = " + str(userInfo[1])  + " IP = " + str(ip)  +"\n"

            self.wfile.write('username=' + str(userInfo[0]) + "&password="+str(userInfo[1]) + "&ip="+str(ip)+"&lease=true")


        # relay the request the IPTV manager
        # - track the channel
        # - track the playback file (session)
        elif re.search(r'/relay/', str(self.path)):
            self.send_response(200)
            self.end_headers()
            reqIPaddress = self.client_address[0]

            results = re.search(r'/relay/([^\/]+)/([^\/]+)$', str(self.path))
            if results:
                channel = str(results.group(1))
                session = str(results.group(2))
                # fetch credentials
                response = urllib2.urlopen(self.server.serverURL + '/get/' + session)
                data = response.read()
                self.wfile.write(data)
                results = re.search(r'username=([^\&]*)&password=([^\&]*)&ip=([^\&]*)', data)
                if results:
                    username = str(results.group(1))
                    password = str(results.group(2))
                    ip = str(results.group(3))
                    if ip == reqIPaddress:
                        ip = '127.0.0.1';
                    print "username = " + username + " password = " + password + " IP = " + ip +"\n"
                    self.server.sessions[session] = username



        elif re.search(r'/free/', str(self.path)):
            self.send_response(200)
            self.end_headers()
            results = re.search(r'/free/([^\/]+)/([^\/]+)$', str(self.path))
            if results:
                username = str(results.group(1))
                session = str(results.group(2))
                self.server.freeCredential(username, session)



        # redirect url to output
        elif re.search(r'/twisted/', str(self.path)):
            print "TWISTED" + "\n\n\n"
            results = re.search(r'/twisted/(.*)$', str(self.path))
            if results:
                url = str(results.group(1))
            self.send_response(301)
            self.send_header('Location','http://' + str(url))
            self.end_headers()

        else:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(self.server.getStats())
            return


