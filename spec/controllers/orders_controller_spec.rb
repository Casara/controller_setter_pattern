require 'spec_helper'

describe OrdersController do
  let(:customer) { create(:customer) }

  context 'with ancestor customer' do
    it 'finds an instance for show' do
      get :show, params: { customer_id: customer.id, id: customer.orders.first.id }
      expect(assigns(:order)).to be_a(Order)
    end

    it 'finds an instance for edit with different name' do
      get :edit, params: { customer_id: customer.id, id: customer.orders.last.id }
      expect(assigns(:other_order)).to be_a(Order)
    end
  end

  it 'finds the instance with params keys for order_by_customer_date' do
    get :order_by_customer_date,
        params: { customer_id: customer.id, order_date: customer.orders.last.order_date.to_date },
        xhr: true
    expect(assigns(:order)).to be_a(Order)
  end
end
