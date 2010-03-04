require  File.expand_path(File.dirname(__FILE__)) + "/../../../../../spec/spec_helper"
require  File.expand_path(File.dirname(__FILE__)) + '/../share_test_helper'

describe Share::TellFeature, :type => :view do

  include ShareTestHelper
  
  reset_domain_tables :email_friends, :content_nodes, :content_types, :site_nodes, :mail_templates, :page_paragraphs

  describe 'share' do 
    it "should be able to render the share feature with default data" do

      
   
     end
    
    
  end
end
 
