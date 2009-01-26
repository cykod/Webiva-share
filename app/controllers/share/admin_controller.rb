class Share::AdminController < ModuleController
  component_info 'Share', :description => 'Site Sharing support - tell-a-friend paragraph / etc ', 
                              :access => :public
                              
  # Register a handler feature
  register_permission_category :share, "Share" ,"Permissions Related Sharing Functionality"
  
  register_permissions :share, [ [ :share_track, 'Track Sharing', 'Whether a user can track sharing links']
                                ]


end
