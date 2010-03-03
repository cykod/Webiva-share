
require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'


describe Share::TellFeature, :type => :view do
  include ShareTestHelper
  reset_domain_tables :email_friends
  
  describe 'share' do 
    
    before(:each) do 
      @feature = build_feature('/share/tell_feature')

    end
    
    
    

    it 'should populate tell form with defaults from options' 
    



 
  end
end
