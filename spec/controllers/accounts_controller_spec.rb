require 'spec_helper'

describe AccountsController do
  let(:supplier) { create(:supplier) }

  context 'with ancestor supplier' do
    it 'finds an instance' do
      get :show, params: { supplier_id: supplier.id, id: supplier.account.id }
      expect(assigns(:account)).to be_a(Account)
    end
  end
end
