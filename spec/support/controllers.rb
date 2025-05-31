# Define a base controller for test purposes that all other test controllers can inherit from.
class ApplicationTestController < ActionController::Base
  # Disable CSRF protection for request specs, as it's typically not needed
  # and can interfere with simple GET/POST requests in a test environment.
  skip_forgery_protection
end

ActionController::Base.include Rails.application.routes.url_helpers
# This might be redundant if routes are used via helpers

class UsersController < ApplicationTestController
  set :user, only: :show

  def show
    render plain: 'show_action'
  end
  # Ping action removed
end

class AccountController < ApplicationTestController
  set :account, model: User, finder_params: :email, only: :resend_password
  set :account, model: User, scope: :active, finder_params: :username, only: :profile
  set :admin_account, model: User, scope: %i[active administrator], finder_params: :username, only: :admin_profile

  def resend_password
    render plain: 'resend_password_action'
  end

  def profile
    render plain: 'profile_action'
  end

  def admin_profile
    render plain: 'admin_profile_action'
  end
end

class OrdersController < ApplicationTestController
  set :customer, only: :show
  set :order, ancestor: :customer, only: :show
  set :other_order, model: Order, ancestor: :customer, only: :edit
  set :order, finder_params: %i[customer_id order_date], only: :order_by_customer_date

  def show
    render plain: 'show_action'
  end

  def edit
    render plain: 'edit_action'
  end

  def order_by_customer_date
    render plain: 'order_by_customer_date_action'
  end
end

class AccountsController < ApplicationTestController
  set :supplier
  set :account, ancestor: :supplier

  def show
    render plain: 'show_action'
  end
end
