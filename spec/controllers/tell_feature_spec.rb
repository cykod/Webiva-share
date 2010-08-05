require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::TellFeature, :type => :view do

  include ShareTestHelper
  describe 'share' do 
    before(:each) do
      @feature = build_feature('/share/tell_feature')      
      @paragraph = mock :id => 17
      @message = Share::TellFriendMessage.new({})
      @myself = mock :id => 24
    end
    it "should be able to render the form" do
      
      data = { :message => @message, :paragraph => @paragraph, :sent => false, :options => Share::TellController::TellFriendOptions.new({}) }
      
      
      @feature.should_receive(:paragraph).and_return(@paragraph)
      @feature.should_receive(:myself).and_return(@myself)
      
      @output = @feature.share_tell_friend_feature(data)
      @output.should include('form action')
      @output.should include(' Enter email addresses (one per line)')
      @output.should include('Message subject:<br/>')
    end
    it "should be able to render the share default data" do
      data = { :message => @message, :paragraph => @paragraph, :sent => false, :options => Share::TellController::TellFriendOptions.new({})  }
      
      @feature.should_receive(:paragraph).and_return(@paragraph)
      @feature.should_receive(:myself).and_return(@myself)
      
      @output = @feature.share_tell_friend_feature(data)
      @output.should include('form action')
    end
    
  end
end

