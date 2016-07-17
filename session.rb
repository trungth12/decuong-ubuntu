require 'sinatra/base'
require 'sinatra/flash'
require "sinatra/activerecord"
require 'bundler'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each {|file| require file }