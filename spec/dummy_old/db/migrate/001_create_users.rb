# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :personal_number
      t.string :role, default: 'user'
      t.string :user_type, default: 'internal'
      t.datetime :last_sign_in_at
      t.integer :sign_in_count, default: 0

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
