require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::ManageController do
  include ShareTestHelper
  
  reset_domain_tables :email_friends
  
  describe 'share' do 
    
    before(:each) do 
      mock_editor  
      stored_email_friends
      stored_email_friends
      stored_email_friends

      Share::ManageController.stub!(:export).and_return('csv')
      controller.stub!(:send_data)
    end
    
    it 'should display previous share emails in a table' do
      post 'tell_friends'
      response.should render_template('share/manage/tell_friends')
    end
    
    it 'should exercise the active table called friend_table' do
      controller.should handle_active_table(:email_friend_table) do |args|
        post 'display_email_friend_table', args
      end
    end
    
    it 'should exercise the statistics table for a share url' do
      controller.should handle_active_table(:email_friend_group_table) do |args|
        post 'display_email_friend_group_table', args       
      end
    end
    
    
    it 'should generate downloads for user statistics' do
      controller.should_receive(:send_data).with(@file, {:filename => "send_to_friend_usr_statistics.csv",  :type => 'text/csv', :disposition => 'attachment'})
      @request.env["HTTP_ACCEPT"] = "text/csv" 
      get :tell_friends_download_all
      
    end

    
    it 'should generate downloads for page statistics' do
      controller.should_receive(:send_data).with([@file], {:filename => "send_to_friend_page_statistics.csv",  :type => 'text/csv', :disposition => 'attachment'})      
      @request.env["HTTP_ACCEPT"] = "text/csv"      
      get :tell_friends_download_all
      
    end
    
    
    it 'should render a view of an email sent' do
      @ind = Share::EmailFriend.find(:first)
      post 'view_email' ,:path => [ @ind.id ] 
      response.should be_success
      
    end
    
  end
end
