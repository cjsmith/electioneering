require File.dirname(__FILE__) + '/spec_helper'

describe "Electioneering" do
  def app
    Sinatra::Application
  end

  it "should respond to /" do
    get '/'
    follow_redirect!
    last_response.should be_ok
    last_response.body.should include("Pick One.")
    last_response.body.should include("Obama")
    last_response.body.should include("Palin")
  end
 
  it "should allow you to vote 3 times" do 
    post '/vote/Obama'
    follow_redirect!
    last_response.should be_ok
    last_response.body.should include("Pick Another One.") 	

    post '/vote/Palin'
    follow_redirect!
    last_response.should be_ok
    last_response.body.should include("Pick One More.")
     
    post '/vote/Obama'
    follow_redirect!
    follow_redirect!
    last_response.should be_ok
    last_response.body.should include("Results")
  end
end

