require 'controller_setter_pattern/action_controller'

# ControllerSetterPattern is the main namespace for this gem.
# Its primary role is to provide the +set+ macro-style method to Rails controllers
# for easily setting up +before_action+ callbacks that define instance variables.
module ControllerSetterPattern
  # This ensures that the ActionController extensions are loaded once ActionController::Base
  # itself has been loaded. This is the standard Rails way to extend framework components.
  ActiveSupport.on_load :action_controller do
    ::ActionController::Base.include ControllerSetterPattern::ActionController
  end
end
