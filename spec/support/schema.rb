ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.integer :status, default: 0
    t.string :name
    t.string :username, unique: true
    t.string :email, unique: true
    t.boolean :admin, default: false
    t.timestamps null: false
  end

  create_table :customers, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :orders, force: true do |t|
    t.belongs_to :customer, index: true
    t.datetime :order_date
    t.timestamps null: false
  end
end