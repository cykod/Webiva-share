require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::TellFriendMessage do
  
  include ShareTestHelper

  before(:each) do
    mock_editor  
  end

  it 'should have a subject' do   
    @share = missing_subject
    @share.valid?.should == false  
  end
 
  it 'should have a message' do  
    @share = missing_message
    @share.valid?.should == false   
  end
  it 'should receive an error when bad email entered' do
    @share = create_message({:manual_to=>'c ykod'})
    @share.valid?
    
 #   raise @share.errors.full_messages.inspect
    @share.errors.on_base.should == "'c ykod' is not a valid email"
    @share.should have(1).errors()    
  end

  it 'should receive an error when no email entered' do
    @share = create_message({:manual_to=>''})
    @share.valid?
    @share.errors.on_base.should == "Please enter one or more email addresses"
    @share.should have(1).errors()
  end
  it 'should have a valid email' do
    @share = create_message({:manual_to=>'daffyduck@cykod.com'})
    @share.valid?.should == true
  end

  it 'create accept more than one email address' do
    @share = create_message({:manual_to=>"tia@cykod.com\r\ntia@mywebiva.net"})
    @share.valid?.should == true
  end
  
  
  it 'create create a list of emails' do
    @share = create_message({:manual_to=>"tia@cykod.com\r\ntia@mywebiva.net"})
    
    @share.valid?.should == true
    @emails = @share.generate_manual_email_list
    @emails[0].should == 'tia@cykod.com'
    @emails[1].should == 'tia@mywebiva.net'

  end
end
