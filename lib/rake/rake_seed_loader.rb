#!/usr/bin/env ruby

# Load the seed files from the command line.

ARGV.each { |f| load f unless f =~ /^-/ or !File.exists?(f) }
