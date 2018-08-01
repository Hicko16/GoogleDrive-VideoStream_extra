'''
    Updates a directory of STRM files

    Copyright (C) 2018 ddurdle

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


import sys
import os
import re
from resources.lib import encryption

#from multiprocessing import Process


import getopt, sys

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "s:p:d:x:z:va", ["help", "directory=", "salt=", "password=", "search=", "replace="])
    except getopt.GetoptError as err:
        # print help information and exit:
        print str(err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    directory = None
    salt = None
    password = None
    search = None
    replace = None
    verbose = False
    decryptOnly = False
    wasEncrypted = False
    for o, a in opts:
        if o in ('-v'):
            verbose = True
        elif o in ('-a'):
            decryptOnly = True
        elif  o in ("-p", "--password"):
            password = a
        elif o in ("-s", "--salt"):
            salt = a
        elif o in ("-h", "--help"):
            print "usage: "
            sys.exit()
        elif o in ("-d", "--directory"):
            directory = a
        elif o in ("-x", "--search"):
            search = a
        elif o in ("-z", "--replace"):
            replace = a
        else:
            assert False, "unhandled option"

    if (directory is None):
        print "No directory (-d) provided."
        print "-d directory [-s salt -p salt password -x search -z replace -a]"
        return

    if (salt is None or password is None):
        print "Crypto salt (-s) or password (-p) not provided."
        return

    encrypt = None
    if (salt is not None and password is not None):
        encrypt = encryption.encryption(salt,password)


    for root,dirs,files in os.walk(directory):
        for filename in files:
            if filename.endswith(".strm"):

                if verbose:
                    print "reading " + str(filename) + "\n"
                file = open(str(root) + '/' + str(filename), "r")
                url = file.read()
                file.close()

                if verbose:
                    print "url = "+ str(url) + "\n"
                m = re.search("kv\=([^\&]+)", url)
                kv = None
                if m:
                    kv = m.group(1)
                    kv = encrypt.decryptString(kv)
                    wasEncrypted = True
                else:
                    kv = url
                m = re.search("^([^\?]+)\?", url)
                baseurl = None
                if m:
                    baseurl = m.group(1)
                    if verbose:
                        print "base url = " + str(baseurl) + "\n"
                else:
                    print "issue with file " + str(root) + '/' + str(filename)

                if verbose:
                    print "kv = " + str(kv) + "\n"
                if (search is not None and replace is not None):
                    kv = kv.replace(search,replace, 5)
                    baseurl = baseurl.replace(search,replace, 5)
                    if verbose:
                        print "kv (with replacements) = " + str(kv) + "\n"
                file = open(str(root) + '/' + str(filename), "w")
                if not decryptOnly:
                    kv = str(baseurl) + '?kv=' + str(encrypt.encryptString(kv))
                file.write(str(kv) + "\n")
                file.close()

                #print "encrypted = " + encrypt.encryptString(kv) + "\n"

                #print "encrypted = " + encrypt.decryptString(encrypt.encryptString(kv)) + "\n"





if __name__ == "__main__":
    main()

