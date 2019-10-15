class Team < ApplicationRecord
  has_many :invoices
  has_many :weeks, through: :invoices
  has_and_belongs_to_many :tags
  # validates :name, :email, presence: true
  # validates :email, uniqueness: true

  after_save do
    if self.bsb.present?
      bsb = BSB.normalize self.bsb
      if BSB.lookup(bsb).present?
        if self.account_number.present?
          self.update_columns(
            bsb: bsb,
            is_validated: true
          )
        else
          self.update_columns(
            bsb: bsb,
            is_validated: false
          )
        end
      else
        if bsb.length == 5
          bsb = "0"+bsb
          if BSB.lookup(bsb).present?
            if self.account_number.present?
              self.update_columns(
                bsb: bsb,
                is_validated: true
              )
            else
              self.update_columns(
                bsb: bsb,
                is_validated: false
              )
            end
          else
            self.update_columns(
              is_validated: false
            )
          end
        end
      end
    else
      self.update_columns(
        is_validated: false
      )
    end
  end

  def check_insurance
    have_insurance = false
    if self.tags.present?
      insurance_titles = ['sm-insurance', 'sm insurance']
      self.tags.each do |tag|
        if insurance_titles.include?(tag.title.downcase)
          have_insurance = true
        end
      end
    end
    if !have_insurance && self.have_insurance_override
      have_insurance = true
    end
    self.update_columns(have_insurance: have_insurance)
  end

end
