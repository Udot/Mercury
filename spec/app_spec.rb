begin 
  require_relative 'spec_helper'
rescue NameError
  require File.expand_path('spec_helper', __FILE__)
end

describe 'Mercury' do

  it 'does not authorize without correct token and username' do
    get '/'
    last_response.status.should == 401
  end
  it 'returns success with correct token and username'
end