# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user
    sequence(:content) { |n| "Comment #{n}" }

    trait :with_long_content do
      content { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 5 }
    end

    trait :recent do
      created_at { rand(1..24).hours.ago }
    end

    trait :old do
      created_at { rand(30..90).days.ago }
    end

    trait :very_old do
      created_at { rand(6..12).months.ago }
    end
  end
end
