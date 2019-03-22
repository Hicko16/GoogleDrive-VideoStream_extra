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
from resources.lib import ffmpegserver
import urllib, urllib2
from SocketServer import ThreadingMixIn
import threading

try:
    port = str(sys.argv[1])
except:
    port = 9999

try:
    ffmpeg = str(sys.argv[2])
except:
    ffmpeg = '/opt/emby-server/bin/ffmpeg'

try:
    ffprobe = str(sys.argv[3])
except:
    ffprobe = '/opt/emby-server/bin/ffprobe'


#try:
server = ffmpegserver.FFMPEGServer(('',  port), ffmpegserver.ffmpegServer)
server.setFFMPEG(ffmpeg)
server.setFFPROBE(ffprobe)
print "FFMPEG Server ready....\n"

while server.ready:
    server.handle_request()
server.socket.close()
#except: pass


#default.run()
