FactoryGirl.define do
  factory :user do
    name     { Faker::Name.name }
    username { Faker::Internet.user_name(name) }
    email    { Faker::Internet.safe_email(username) }
  end

  factory :customer do
    name { Faker::Company.name }
    after(:create) { |customer| create_list(:order, 3, customer: customer) }
  end

  factory :order do
    customer
    order_date { Faker::Date.forward(90) }
  end
end