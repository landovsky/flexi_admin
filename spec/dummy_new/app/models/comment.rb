# frozen_string_literal: true

class Comment < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource

  belongs_to :user

  validates :content, presence: true

  # Required for GlobalID
  include GlobalID::Identification
end
