require 'rack/test'

begin 
  require_relative '../app.rb'
rescue NameError
  require File.expand_path('../app.rb', __FILE__)
end

module RSpecMixin
  include Rack::Test::Methods
  def app() Mercury.new end
end

RSpec.configure { |c| c.include RSpecMixin }