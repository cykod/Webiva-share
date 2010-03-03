

require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::ManageController do
  include ShareTestHelper
  reset_domain_tables :email_friends
  
  describe 'share' do 
    
    before(:each) do 
      mock_editor
      
    end
    it 'should limit email based on configuration option'
    it 'should accept multiple addresses'
    it 'should error wtihout email address'
    it 'should error with invalid email address'
    it 'should error without a subject if set in options'
    it 'should error without a message if set in options'
    it 'should redirect on success if page is set in options'
    
  end
end
