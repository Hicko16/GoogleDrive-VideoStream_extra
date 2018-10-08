#!/usr/bin/perl
#
# sample program that fetches a username / password for IPTV and then releases it

require './crawler.pm';
TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::complexGET('http://localhost:9998/get/',undef,[],[],[('username\=', '\&', '\&'),('password\=', '\&', '\&')]);

print "username = $results[3], password = $results[5]\n";

TOOLS_CRAWLER::simpleGET('http://localhost:9998/free/test1');


