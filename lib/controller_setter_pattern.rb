require 'controller_setter_pattern/action_controller'

ActiveSupport.on_load :action_controller do
  ActionController::Base.include ControllerSetterPattern::ActionController
end
