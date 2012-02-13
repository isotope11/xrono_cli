lib_dir = File.expand_path '..', __FILE__
$:.unshift lib_dir unless $:.include? lib_dir

require 'command_line_reporter'
require 'thor'
require 'httparty'
require 'grit'

require 'xcli/configuration'
require 'xcli/cli'
