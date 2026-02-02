# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user
    sequence(:content) { |n| "Comment #{n}" }

    trait :with_long_content do
      content { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 5 }
    end
  end
end
