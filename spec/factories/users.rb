# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:full_name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    phone { "+420 #{rand(100_000_000..999_999_999)}" }
    sequence(:personal_number) { |n| "PN#{n.to_s.rjust(6, '0')}" }
    role { 'user' }
    user_type { 'internal' }
    last_sign_in_at { rand(1..30).days.ago }
    sign_in_count { rand(1..100) }

    trait :admin do
      role { 'admin' }
    end

    trait :external do
      user_type { 'external' }
    end

    trait :balicka do
      full_name { 'Balická' }
      email { 'balicka@hristehrou.cz' }
      role { 'admin' }
    end

    trait :effenberger do
      full_name { 'Effenberger' }
      email { 'effenberger@example.com' }
    end

    trait :recent_login do
      last_sign_in_at { 1.hour.ago }
    end

    trait :old_login do
      last_sign_in_at { 90.days.ago }
    end
  end
end
