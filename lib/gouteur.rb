require 'bundler'

require 'gouteur/bundle'
require 'gouteur/checker'
require 'gouteur/cli'
require 'gouteur/dotfile'
require 'gouteur/host'
require 'gouteur/message'
require 'gouteur/repo'
require 'gouteur/shell'
require 'gouteur/version'

# :nodoc:
module Gouteur
  class Error < StandardError; end
end
