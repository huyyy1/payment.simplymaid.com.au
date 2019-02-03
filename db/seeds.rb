# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

p "Create users"
u = User.create(email: "alex.shkolnikov@gmail.com", password: "testpassword3")
u.is_admin = true
u.save

p "Import teams"
CSV.foreach(Rails.root.join('data', 'export.csv'), encoding: "utf-8", headers: :first_row) do |row|
  Team.create(
    name: row[0],
    email: row[1],
    is_gst: row[2].downcase == "yes" ? true : false,
    abn: row[3].gsub(" ",""),
    billing_name: row[4],
    address: row[5],
    bsb: row[6].gsub("-",""),
    account_number: row[7].gsub(" ",""),
    notes: row[8]
  )
end