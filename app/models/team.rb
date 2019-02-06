class Team < ApplicationRecord
  has_many :invoices
  has_many :weeks, through: :invoices
  has_and_belongs_to_many :tags
end
