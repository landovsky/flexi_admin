# frozen_string_literal: true

require 'global_id'

class User < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource

  has_many :comments, dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true

  # Fulltext search scope for autocomplete
  scope :fulltext, ->(query) {
    return all if query.blank?

    search_term = "%#{query}%"
    where('full_name LIKE ? OR email LIKE ?', search_term, search_term)
  }

  # Title method for autocomplete display
  def title
    full_name
  end

  # Alias for autocomplete
  alias_method :ac_title, :title

  # Simulate last_login tracking
  def last_login
    last_sign_in_at
  end

  # Required for GlobalID
  include GlobalID::Identification
end
