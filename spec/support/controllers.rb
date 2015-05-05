load File.dirname(__FILE__) + '/routes.rb'

ActionController::Base.include Rails.application.routes.url_helpers

class UsersController < ActionController::Base
  set :user, only: :show

  def show
    render json: @user
  end
end

class AccountController < ActionController::Base
  set :account, model: User, finder_params: :email, only: :resend_password
  set :account, model: User, scope: :active, finder_params: :username, only: :profile
  set :admin_account, model: User, scope: [:active, :administrator], finder_params: :username, only: :admin_profile

  def resend_password
    render text: "An email containing the new password was sent to your inbox (#{@account.email})."
  end

  def profile
    render json: @account
  end

  def admin_profile
    render json: @admin_account
  end
end

class OrdersController < ActionController::Base
  set :customer, only: :show
  set :order, ancestor: :customer, only: :show
  set :other_order, model: Order, ancestor: :customer, only: :edit
  set :order, finder_params: [:customer_id, :order_date], only: :order_by_customer_date

  def show
    render json: @order
  end

  def edit
    render text: 'Edit'
  end

  def order_by_customer_date
    render json: @order
  end
end