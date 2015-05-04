require 'controller_setter_pattern/action_controller'

ActiveSupport.on_load :action_controller do
  ActionController::Base.send :include, ControllerSetterPattern::ActionController
end