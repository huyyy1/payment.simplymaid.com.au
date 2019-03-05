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

u = User.create(email: "huy@simplymaid.com.au", password: "testpassword3")
u.is_admin = true
u.save

p "Import teams"
CSV.foreach(Rails.root.join('data', 'export.csv'), encoding: "utf-8", headers: :first_row) do |row|
  Team.create(
    name: row[0],
    email: row[1],
    is_gst: row[2].downcase == "yes" ? true : false,
    is_confirmed: true,
    abn: row[3].gsub(" ",""),
    billing_name: row[4],
    address: row[5],
    bsb: row[6].gsub("-",""),
    account_number: row[7].gsub(" ",""),
    notes: row[8]
  )
end

p "Create weeks"
start_date = Date.new(2018,10,7)
while start_date < Date.new(2021,10,7) do
  Week.create(
    start_date: start_date,
    end_date: start_date + 6.days,
    payment_date: start_date + 10.days
  )
  start_date = start_date + 7.days
end
