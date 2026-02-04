# frozen_string_literal: true

require 'global_id'

class User < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource

  has_many :comments, dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true

  # Simulate last_login tracking
  def last_login
    last_sign_in_at
  end

  # Required for GlobalID
  include GlobalID::Identification
end
