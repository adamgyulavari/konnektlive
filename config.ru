require 'sinatra'
require 'haml'
require 'sass'
require 'sass/plugin/rack'
require './konnekt_live'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack
run KonnektLive
