require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::ManageController do
  include ShareTestHelper
  
  reset_domain_tables :email_friends
  
  require 'csv'

  describe 'share' do 
    
    before(:each) do 
      mock_editor  
      stored_email_friends
      stored_email_friends
      stored_email_friends

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
        post 'download_page_statistics_data'       
      end
    end
    it 'should render a view of an email sent' do
      @ind = Share::EmailFriend.find(:first)
      post('view_email' ,:path => [ @ind.id ] )
    end
    describe 'exporting data' do          
      describe 'user statistics' do
        before(:each) do
          @request.env["HTTP_ACCEPT"] = "text/csv"      

          @user_file = 'send_to_friend_user_statistics.csv'
        end
        it 'should be successful' do
          get :tell_friends_download_all

          response.should be_success      
        end   
        
        it 'should generate downloads for user statistics' do
          controller.should_receive(:send_data)
          get :tell_friends_download_all      

        end   
      end
      describe 'page statistics' do
        before(:each) do
          @page_file = "send_to_friend_page_statistics.csv"
          @request.env["HTTP_ACCEPT"] = "text/csv"      
        end
        it 'should be successful' do
           get :download_page_statistics_data 

          response.should be_success      
        end
        it 'should generate downloads for page statistics' do    
          controller.should_receive(:send_data)
           get :download_page_statistics_data 
        end
        
      end
    end
  end
end
