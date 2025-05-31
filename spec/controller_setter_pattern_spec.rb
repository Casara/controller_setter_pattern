require 'spec_helper'

describe ControllerSetterPattern do
  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  context 'when included in ActionController' do
    describe UsersController, type: :controller do
      let!(:users) { create_list(:user, 3) }
      let(:user) { users.first }

      context 'when finding with params[:id]' do
        before { get :show, params: { id: user.id } }

        it 'assigns a User instance' do
          expect(assigns(:user)).to be_a(User)
        end

        it 'assigns the correct user' do
          expect(assigns(:user)).to eq(user)
        end
      end

      context 'when finding with params[:user_id]' do
        before { get :show, params: { user_id: user.id } }

        it 'assigns a User instance' do
          expect(assigns(:user)).to be_a(User)
        end

        it 'assigns the correct user' do
          expect(assigns(:user)).to eq(user)
        end
      end
    end

    describe AccountController, type: :controller do
      let!(:user) { create(:user) }

      context 'with a model name and a parameter key' do
        context 'when finding for resend_password with email' do
          before { get :resend_password, params: { email: user.email } }

          it 'assigns an account (User instance)' do
            expect(assigns(:account)).to be_a(User)
          end

          it 'assigns the correct user as account' do
            expect(assigns(:account)).to eq(user)
          end
        end

        context 'when finding for profile with scope username' do
          before { get :profile, params: { username: user.username } }

          it 'assigns an account (User instance)' do
            expect(assigns(:account)).to be_a(User)
          end

          it 'assigns the correct user as account' do
            expect(assigns(:account)).to eq(user)
          end
        end

        context 'when finding for admin_profile with scopes' do
          before { get :admin_profile, params: { username: user.username } }

          it 'assigns an admin_account (User instance)' do
            expect(assigns(:admin_account)).to be_a(User)
          end

          it 'assigns the correct user as admin_account' do
            expect(assigns(:admin_account)).to eq(user)
          end
        end
      end
    end

    describe OrdersController, type: :controller do
      let!(:customer) { create(:customer) } # Factory should create associated orders
      let!(:first_order) { customer.orders.first }
      let!(:last_order) { customer.orders.last }

      context 'with ancestor customer' do
        context 'when finding an instance for show' do
          before { get :show, params: { customer_id: customer.id, id: first_order.id } }

          it 'assigns an Order instance to @order' do
            expect(assigns(:order)).to be_a(Order)
          end

          it 'assigns the correct order to @order' do
            expect(assigns(:order)).to eq(first_order)
          end
        end

        context 'when finding an instance for edit with different name' do
          before { get :edit, params: { customer_id: customer.id, id: last_order.id } }

          it 'assigns an Order instance to @other_order' do
            expect(assigns(:other_order)).to be_a(Order)
          end

          it 'assigns the correct order to @other_order' do
            expect(assigns(:other_order)).to eq(last_order)
          end
        end
      end

      context 'when finding the instance with params keys for order_by_customer_date' do
        before do
          get :order_by_customer_date,
              params: { customer_id: customer.id, order_date: last_order.order_date.to_date },
              xhr: true
        end

        it 'assigns an Order instance' do
          expect(assigns(:order)).to be_a(Order)
        end

        it 'assigns an order for the correct customer' do
          expect(assigns(:order).customer_id).to eq(customer.id)
        end

        it 'assigns an order with the correct date' do
          expect(assigns(:order).order_date.to_date).to eq(last_order.order_date.to_date)
        end
      end
    end

    describe AccountsController, type: :controller do
      let!(:supplier) { create(:supplier) } # Factory should create associated account
      let!(:account) { supplier.account }

      context 'with ancestor supplier' do
        context 'when finding an instance for show' do
          before { get :show, params: { supplier_id: supplier.id, id: account.id } }

          it 'assigns an Account instance' do
            expect(assigns(:account)).to be_a(Account)
          end

          it 'assigns the correct account' do
            expect(assigns(:account)).to eq(account)
          end
        end
      end
    end
  end
end
