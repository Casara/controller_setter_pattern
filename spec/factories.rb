# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name     { Faker::Name.name }
    # For username, if you want it based on name, it's more complex.
    # Using a simpler, independent Faker method for now to avoid linting errors.
    username { Faker::Internet.username }
    email    { Faker::Internet.email } # Changed from safe_email, and removed argument
    admin    { false }

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
    order_date { Faker::Date.forward(days: 90).beginning_of_day } # Use keyword argument and set to beginning of day
  end

  factory :supplier do
    name { Faker::Company.name }
    account { FactoryBot.create(:account) }
  end

  factory :account do
    account_number { Faker::Number.number(digits: 10) } # Use keyword argument
  end
end
