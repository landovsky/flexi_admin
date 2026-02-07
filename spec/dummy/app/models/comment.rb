# frozen_string_literal: true

require 'global_id'

class Comment < ApplicationRecord
  include FlexiAdmin::Models::Concerns::ApplicationResource

  belongs_to :user

  validates :content, presence: true
  alias_attribute :body, :content

  # Required for GlobalID
  include GlobalID::Identification
end
