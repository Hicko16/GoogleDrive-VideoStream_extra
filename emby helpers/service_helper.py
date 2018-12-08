'''
    Copyright (C) 2013-2017 ddurdle

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
from resources.lib import webproxy
import urllib, urllib2
from SocketServer import ThreadingMixIn
import threading
import sys


try:
    serverURL = str(sys.argv[1])
except:
    print "Specify a server URL\n"
    serverURL = ''


try:
    key = str(sys.argv[2])
except:
    print "Specify a key\n"
    key = ''

try:
    manual = str(sys.argv[3])
except:
    print "Specify a manual message\n"
    manual = ''

try:
    port = int(sys.argv[4])
except:
    port = 9993

if serverURL != '':
    server = webproxy.WebProxyServer(('',  port), webproxy.webProxy)
    server.setServer(serverURL, key, manual)
    print "Emby Service Helper ready....\n"

    while server.ready:
        server.handle_request()
    server.socket.close()


