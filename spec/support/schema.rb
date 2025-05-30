ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.integer :status, default: 0
    t.string :name
    t.string :username
    t.string :email
    t.boolean :admin, default: false
    t.timestamps null: false
  end
  add_index :users, :username, unique: true
  add_index :users, :email, unique: true

  create_table :customers, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :orders, force: true do |t|
    t.belongs_to :customer, index: true
    t.datetime :order_date
    t.timestamps null: false
  end

  create_table :suppliers, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :accounts, force: true do |t|
    t.belongs_to :supplier, index: true
    t.string :account_number
    t.timestamps null: false
  end
end