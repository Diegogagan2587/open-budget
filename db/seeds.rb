# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Default Categories
default_categories = [
  "Food",
  "Transport",
  "Taxes",
  "Commissions and Interest",
  "Home"
]

default_categories.each do |category_name|
  Category.find_or_create_by!(name: category_name)
end

puts "Seeded #{default_categories.count} default categories"
