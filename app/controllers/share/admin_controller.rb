class Share::AdminController < ModuleController
  permit 'editor'

  component_info 'Share', :description => "See emails sent with Tell-a-friend", 
  :access => :public
  
  register_permissions :editor, [ [:share, 'Share', 'Permissions related to Share'] ]
  
  module_for :mail, 'Mail', :description => 'Add E-Marketing Pages to your site'

  user_actions :mail

  register_handler :navigation, :emarketing, "Share::AdminController"

  def self.navigation_emarketing_handler_info
    {:name => 'E-Marketing Pages',
      :pages => [ [ "Tell a Friend", :editor_mailing, "emarketing_campaigns.gif", {  :controller => '/share/manage', :action => 'tell_friends' },
                    "blahblahblah" ]
                ]
    }
  end
  
end
