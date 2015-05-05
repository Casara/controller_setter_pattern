require 'spec_helper'

describe ControllerSetterPattern do
  it 'is a model' do
    expect(ControllerSetterPattern).to be_a(Module)
  end
end

describe UsersController, type: :controller do
  before { FactoryGirl.create_list(:user, 3) }

  let(:user) { User.first }

  subject { assigns(:user) }

  it 'finds the instance with params[:id]' do
    get :show, id: user.id
    should be_a(User)
  end

  it 'finds the instance with params[:model_id]' do
    get :show, user_id: user.id
    should be_a(User)
  end
end

describe AccountController, type: :controller do
  before { FactoryGirl.create_list(:user, 3) }

  let(:user) { User.first }

  subject { assigns(:account) }

  context 'with a model name and a parameter key' do
    it 'finds an instance' do
      get :resend_password, email: user.email
      should be_a(User)
    end

    it 'finds an instance with scope' do
      get :profile, username: user.username
      should be_a(User)
    end

    it 'finds the instance with scopes' do
      get :admin_profile, username: user.username
      expect(assigns(:admin_account)).to be_a(User)
    end
  end
end

describe OrdersController, type: :controller do
  let(:customer) { FactoryGirl.create(:customer) }

  context 'with ancestor' do
    it 'finds an instance' do
      get :show, customer_id: customer.id, id: customer.orders.first.id
      expect(assigns(:order)).to be_a(Order)
    end

    it 'assigns based on ancestor model class and model name' do
      get :edit, customer_id: customer.id, id: customer.orders.last.id
      expect(assigns(:other_order)).to be_a(Order)
    end
  end

  it 'finds the instance with params keys' do
    xhr :get, :order_by_customer_date, customer_id: customer.id, order_date: customer.orders.last.order_date.to_date
    expect(assigns(:order)).to be_a(Order)
  end
end