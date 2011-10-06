#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

get '/' do
  @host = request.host
  haml :index
end
