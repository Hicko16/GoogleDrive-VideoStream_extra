#!/usr/bin/perl
#
# sample program that fetches a username / password for IPTV and then releases it

require './crawler.pm';
TOOLS_CRAWLER::ignoreCookies();

my$hostname = 'test.monkeydevices.com:9998';
my @results = TOOLS_CRAWLER::complexGET('http://'.$hostname.'/get/',undef,[],[],[('username\=', '\&', '\&'),('password\=', '\&', '\&')]);

print "username = $results[3], password = $results[5]\n";

TOOLS_CRAWLER::simpleGET('http://'.$hostname.'/free/'.$results[3]);


