# setup proper paths and stuff
require "rubygems"
require 'libglade2'
require "yaml"
require "ostruct"
SWAT_APP = File.expand_path(File.dirname(__FILE__)+"/..")
["lib"].each { |x| $LOAD_PATH.unshift("#{SWAT_APP}/#{x}"); $LOAD_PATH.unshift("#{SWAT_APP}/#{x}/keybinder")}
