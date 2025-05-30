require 'spec_helper'

describe ControllerSetterPattern do
  it 'is a model' do
    expect(described_class).to be_a(Module)
  end

  context 'when included in ActionController' do
    describe UsersController, type: :controller do
      # subject { assigns(:user) } # Removed explicit subject

      before { create_list(:user, 3) }

      let(:user) { User.first }

      it 'finds the instance with params[:id]' do
        get :show, params: { id: user.id }
        expect(assigns(:user)).to be_a(User) # Use assigns directly
      end

      it 'finds the instance with params[:model_id]' do
        get :show, params: { user_id: user.id }
        expect(assigns(:user)).to be_a(User) # Use assigns directly
      end
    end

    describe AccountController, type: :controller do
      # subject { assigns(:account) } # Removed explicit subject

      before { create_list(:user, 3) }

      let(:user) { User.first }

      context 'with a model name and a parameter key' do
        it 'finds an instance' do
          get :resend_password, params: { email: user.email }
          expect(assigns(:account)).to be_a(User) # Use assigns directly
        end

        it 'finds an instance with scope' do
          get :profile, params: { username: user.username }
          expect(assigns(:account)).to be_a(User) # Use assigns directly
        end

        it 'finds the instance with scopes' do
          get :admin_profile, params: { username: user.username }
          expect(assigns(:admin_account)).to be_a(User)
        end
      end
    end

    describe OrdersController, type: :controller do
      let(:customer) { create(:customer) }

      context 'with ancestor' do
        it 'finds an instance' do
          get :show, params: { customer_id: customer.id, id: customer.orders.first.id }
          expect(assigns(:order)).to be_a(Order)
        end

        it 'assigns based on ancestor model class and model name' do
          get :edit, params: { customer_id: customer.id, id: customer.orders.last.id }
          expect(assigns(:other_order)).to be_a(Order)
        end
      end

      it 'finds the instance with params keys' do
        get :order_by_customer_date,
            params: { customer_id: customer.id, order_date: customer.orders.last.order_date.to_date }, xhr: true
        expect(assigns(:order)).to be_a(Order)
      end
    end

    describe AccountsController, type: :controller do
      let(:supplier) { create(:supplier) }

      context 'with ancestor' do
        it 'finds an instance' do
          get :show, params: { supplier_id: supplier.id, id: supplier.account.id }
          expect(assigns(:account)).to be_a(Account)
        end
      end
    end
  end
end
