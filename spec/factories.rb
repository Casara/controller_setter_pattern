FactoryGirl.define do
  factory :user do
    name     { Faker::Name.name }
    username { Faker::Internet.user_name(name) }
    email    { Faker::Internet.safe_email(username) }
    admin    false

    after(:create) do |user, evaluator|
      if evaluator.id == 1
        user.admin = true
        user.active!
      end
    end
  end

  factory :customer do
    name { Faker::Company.name }
    after(:create) { |customer| create_list(:order, 3, customer: customer) }
  end

  factory :order do
    customer
    order_date { Faker::Date.forward(90) }
  end

  factory :supplier do
    name { Faker::Company.name }
    account { FactoryGirl.create(:account) }
  end

  factory :account do
    account_number { Faker::Number.number(10) }
  end
end