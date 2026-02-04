# frozen_string_literal: true

# Clear existing data
Comment.destroy_all
User.destroy_all

puts "Creating sample users..."

# Create users
users = [
  { full_name: "Jan Novák", email: "jan.novak@example.com", role: "admin", user_type: "internal", phone: "+420 123 456 789", personal_number: "12345" },
  { full_name: "Marie Svobodová", email: "marie.svobodova@example.com", role: "user", user_type: "internal", phone: "+420 987 654 321" },
  { full_name: "Petr Dvořák", email: "petr.dvorak@example.com", role: "admin", user_type: "external" },
  { full_name: "Jana Nováková", email: "jana.novakova@example.com", role: "user", user_type: "internal" },
  { full_name: "Tomáš Černý", email: "tomas.cerny@example.com", role: "user", user_type: "external" },
  { full_name: "Petra Procházková", email: "petra.prochazkova@example.com", role: "admin", user_type: "internal" },
  { full_name: "Martin Veselý", email: "martin.vesely@example.com", role: "user", user_type: "internal" },
  { full_name: "Eva Marková", email: "eva.markova@example.com", role: "user", user_type: "external" }
]

created_users = users.map do |user_attrs|
  User.create!(user_attrs.merge(
    last_sign_in_at: rand(1..30).days.ago,
    sign_in_count: rand(1..50)
  ))
end

puts "Created #{created_users.count} users"

# Create comments
puts "Creating sample comments..."

comments_data = [
  "Výborná práce!",
  "Potřebujeme to upravit.",
  "Souhlasím s návrhem.",
  "Mám dotaz ohledně implementace.",
  "Skvělý nápad!"
]

created_users.each do |user|
  rand(1..3).times do
    Comment.create!(
      user: user,
      content: comments_data.sample
    )
  end
end

puts "Created #{Comment.count} comments"
puts "Seed data created successfully!"
