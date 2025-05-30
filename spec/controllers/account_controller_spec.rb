require 'spec_helper'

describe AccountController do
  before { create_list(:user, 3) }

  let(:user) { User.first }

  context 'with a model name and a parameter key' do
    it 'finds an instance with email' do
      get :resend_password, params: { email: user.email }
      expect(assigns(:account)).to be_a(User)
    end

    it 'finds an instance with scope username' do
      get :profile, params: { username: user.username }
      expect(assigns(:account)).to be_a(User)
    end

    it 'finds the instance with scopes in admin' do
      get :admin_profile, params: { username: user.username }
      expect(assigns(:admin_account)).to be_a(User)
    end
  end
end
