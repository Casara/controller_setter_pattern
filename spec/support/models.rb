load File.dirname(__FILE__) + '/schema.rb'

class User < ActiveRecord::Base
  has_many :social_networks

  enum status: {
    passive: 0,
    pending: 1,
    active: 2,
    locked: 3
  }

  validates_uniqueness_of :email, case_sensitive: false
  validates_uniqueness_of :username, case_sensitive: false

  before_save { |record| record.status = 'pending' if record.passive? }
end

class Customer < ActiveRecord::Base
  has_many :orders, dependent: :destroy
end

class Order < ActiveRecord::Base
  belongs_to :customer
end