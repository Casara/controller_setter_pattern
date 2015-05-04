Rails.application.routes.draw do
  get 'user/(:id)' => 'users#show'

  get 'resend_password/:email' => 'account#resend_password'
  get 'profile/:username' => 'account#profile'

  get 'customers/:customer_id/orders/:id' => 'orders#show'
  get 'customers/:customer_id/orders/:id/edit' => 'orders#edit', as: :edit
  get 'order_by_customer_date' => 'orders#order_by_customer_date'
end