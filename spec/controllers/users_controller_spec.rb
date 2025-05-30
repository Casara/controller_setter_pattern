require 'spec_helper'

describe UsersController do
  before { create_list(:user, 3) }

  let(:user) { User.first }

  it 'finds the instance with params[:id]' do
    get :show, params: { id: user.id }
    expect(assigns(:user)).to be_a(User)
  end

  it 'finds the instance with params[:user_id]' do
    get :show, params: { user_id: user.id }
    expect(assigns(:user)).to be_a(User)
  end
end
