

require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::TellRenderer, :type => :controller  do
  include ShareTestHelper
  reset_domain_tables :email_friends, :mail_templates, :page_paragraphs
  
  controller_name :page

  integrate_views

  before(:each) do 
    mock_user

    MailTemplate.create(:name => "M Template Test 1", :language => 'eng', :template_type => 'site', :body_type => 'text',:subject =>  'Test Template', :body_text => "hihi")

  end

  def share_renderer(options={},inputs={})
    build_renderer('/page','/share/tell/tell_friend',options,inputs)
  end

  
  it 'should limit email based on configuration option' do
    @ran_limit = 1 + rand(50)
    options = {:email_limit => @ran_limit}
    inputs = {}
    @rnd = share_renderer(options, inputs)
    
    @rnd.should_render_feature( :share_tell_friend )
    renderer_get( @rnd )
    @rnd.renderer_feature_data[:options].email_limit.should == @ran_limit

    
  end

  
  
  it 'should accept multiple addresses' do 
    options = {:email_template_id => 1}
    inputs = {}
    @rnd = share_renderer(options, inputs)
    @rnd.should_render_feature( :share_tell_friend )

    renderer_post @rnd, { 'tell_friend_1' => { :manual_to => 'daffyduck@mywebiva.net\r\nbugsbunny@mywebiva.net', :message => 'Test Message', :subject => 'Test Subject'} }
  end
  it 'should error without email address '  do
    options = {:email_template_id => 1}
    
    inputs = {}
    @rnd = share_renderer(options, inputs)
    @rnd.should_render_feature( :share_tell_friend )

    renderer_post @rnd, { "tell_friend_1" => { :manual_to => '', :message => 'Test Message', :subject => 'Test Subject'} }
    @rnd.renderer_feature_data[:message].errors[:base].should == "Please enter one or more email addresses"
  end    
  
  it 'should error with invalid email address' do  
    options = {:email_template_id => 1}

    inputs = {}
    @rnd = share_renderer(options, inputs)
            @rnd.should_render_feature( :share_tell_friend )

    renderer_post @rnd, { "tell_friend_1" => { :manual_to => 'daffyd uck@mywebiva.net', :message => 'Test Message', :subject => 'Test Subject'} }
    @rnd.renderer_feature_data[:message].errors[:base].should == "'daffyd uck@mywebiva.net' is not a valid email"

  end
  it 'should error without a subject if set in options on post' do
    options = {:email_template_id => 1}

    inputs = {}
    @rnd = share_renderer(options, inputs)
            @rnd.should_render_feature( :share_tell_friend )
    renderer_post @rnd, { "tell_friend_1" => { :manual_to => 'daffyduck@mywebiva.net', :message => 'Test Message', :subject => ''} }
    @rnd.renderer_feature_data[:message].errors[:base].should == "Please enter a subject"
  end
  it 'should error without a message if set in options' do 
    
    options = {:email_limit => 5, :email_template_id => 1}
    
    inputs = {}
    @rnd = share_renderer(options, inputs)
    
    @rnd.should_render_feature( :share_tell_friend )
    renderer_post @rnd, { "tell_friend_1" => { :manual_to => 'daffyduck@mywebiva.net', :message => '', :subject => 'Test Subject'} }
   @rnd.renderer_feature_data[:message].errors[:base].should == "Please enter a message"

  end
  it 'should redirect on success if page is set in options' do 
    options = {:email_template_id => 1, :success_page_id => 3}
    inputs = {}
    @rnd = share_renderer(options, inputs)
    @rnd.should_receive(:redirect_paragraph).with(:site_node => 3)
    renderer_post @rnd, { "tell_friend_1" => { :manual_to => 'daffyduck@mywebiva.net', :message => 'HIdy Ho', :subject => 'Test Subject'} }
  end
end
