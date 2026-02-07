# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Test Infrastructure', type: :model do
  it 'sets up database connection' do
    expect(ActiveRecord::Base.connection).to be_present
  end

  it 'creates User model' do
    user = User.create!(
      full_name: 'Test User',
      email: 'test@example.com'
    )
    expect(user).to be_persisted
    expect(user.full_name).to eq('Test User')
  end

  it 'creates Comment model with association' do
    user = User.create!(full_name: 'Test User', email: 'test@example.com')
    comment = Comment.create!(user: user, content: 'Test comment')

    expect(comment).to be_persisted
    expect(comment.user).to eq(user)
  end

  it 'loads factories' do
    user = build(:user)
    expect(user).to be_a(User)
    expect(user.full_name).to be_present
  end
end
