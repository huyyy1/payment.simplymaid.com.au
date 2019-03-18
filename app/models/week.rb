class Week < ApplicationRecord
  has_many :invoices
  has_many :teams, through: :invoices

  default_scope { order("start_date DESC") }

  scope :past, -> { where('payment_date <= ?', Time.now + 4.days) }

  def to_pay_count
    week = self
    Invoice.not_empty.where(week_id: week.id).count
  end

  def all_count
    week = self
    Invoice.where(week_id: week.id).count
  end

  def total_due
    week = self
    Invoice.where(week_id: week.id).sum(:due)
  end

  def is_past
    self.payment_date < (Time.now - 10.days) ? true : false
  end

  def parse
    # "alex.shkolnikov@gmail.com"
    # "bozqiv-duwwoc-fybzA4"

    week = self

    if week.is_parsed
      week.update_columns(
        is_parsed: false,
        parsed_at: nil,
        is_processed: false,
        processed_at: nil
      )
      Invoice.where(week_id: week.id).destroy_all
    end

    response = RestClient.post 'https://simplymaidaus.launch27.com/v1/login', {email: "alex.shkolnikov@gmail.com", password: "bozqiv-duwwoc-fybzA4"}.to_json, {content_type: :json, accept: :json}

    if response.code == 200
      result = JSON.parse(response.body)
      bearer = result["bearer"]

      page = 0
      finished = false

      until finished do
        results = RestClient.get "https://simplymaidaus.launch27.com/v1/staff/teams/payments/summary?from=#{week.start_date.strftime("%Y-%m-%d")}&limit=50&offset=#{page*50}&to=#{week.end_date.strftime("%Y-%m-%d")}", {content_type: :json, accept: :json, Authorization: "Bearer #{bearer}"}
        results_array = JSON.parse(results)

        results_array.each do |result_json|
          if result_json["team"].present?
            @team = Team.where(name: result_json["team"]["title"]).first_or_create do |team|
              team.first_name = result_json["team"]["first_name"]
              team.last_name = result_json["team"]["last_name"]
              team.launch_id = result_json["team"]["id"]
              team.email = result_json["team"]["email"]
              team.status = result_json["team"]["active"]
            end
            if result_json["team"]["tags_info"].present?
              result_json["team"]["tags_info"].each do |tag_json|
                @tag = Tag.where(launch_id: tag_json["id"]).first_or_create do |tag|
                  tag.title = tag_json["name"]
                  tag.color = tag_json["color"]
                  tag.tag_type = tag_json["type"]
                  tag.ordering = tag_json["ordering"]
                end
                @team.tags << @tag
              end
            end

            @invoice = Invoice.create(
              team_id: @team.id,
              week_id: week.id,
              earned: result_json["earned"],
              tips: result_json["tips"],
              adjustments: result_json["adjustments"],
              due: result_json["due"],
              paid: result_json["paid"],
              wages_hourly: result_json["wages"]["hourly"],
              wages_share: result_json["wages"]["share"],
              wages_service_price_only: result_json["wages"]["service_price_only"],
              wages_fee_amount: result_json["wages"]["fee"]["amount"],
              wages_fee_percent: result_json["wages"]["fee"]["percent"],
              hours_earned: result_json["hours"]["earned"],
              hours_scheduled: result_json["hours"]["scheduled"]
            )
          end
        end

        if results_array.count < 50
          finished = true
        end

        page = page + 1
      end
      week.update_columns(
        is_parsed: true,
        parsed_at: Time.now,
        payment_total: week.total_due
      )
    end
  end

  def create_aba
    week = self

    aba_gst = false
    aba_no_gst = false

    invoices = Invoice.includes(:team).not_empty.where(week_id: week.id).find_each do |invoice|
      if invoice.team.is_gst
        aba_gst = true
      else
        aba_no_gst = true
      end
    end

    result = {
      success: false,
      data_gst: nil,
      data_no_gst: nil,
      errors: nil
    }

    if aba_gst
      aba = Aba.batch(
        bsb: "062-256", # Optional (Not required by NAB)
        financial_institution: "CBA",
        user_name: "SIMPLY MAID",
        user_id: 301500,
        description: "GST",
        process_at: Time.now.strftime("%d%m%y")
      )

      invoices = Invoice.includes(:team).not_empty.where(week_id: week.id).find_each do |invoice|
        if invoice.team.is_validated && invoice.team.is_gst && invoice.due > 0
          bsb = invoice.team.bsb
          bsb = bsb[0..2]+"-"+bsb[3..5]
          aba.add_transaction(
            {
              bsb: bsb,
              account_number: invoice.team.account_number,
              amount: (invoice.due*100).to_i, # Amount in cents
              account_name: invoice.team.name,
              transaction_code: 53,
              lodgement_reference: "SIMPLY MAID", #gst add here
              name_of_remitter: "SIMPLY MAID"
            }
          )
        end
      end
      if aba.valid?
        week.update_attributes(
          aba_file_gst: aba.to_s,
          aba_created_at: Time.now
        )
        result[:success] = true
        result[:data_gst] = aba.to_s
      else
        result[:success] = false
        result[:errors] = aba.errors
      end
    end

    if aba_no_gst
      aba2 = Aba.batch(
        bsb: "062-256", # Optional (Not required by NAB)
        financial_institution: "CBA",
        user_name: "SIMPLY MAID",
        user_id: 301500,
        description: "NO_GST",
        process_at: Time.now.strftime("%d%m%y")
      )

      invoices = Invoice.includes(:team).not_empty.where(week_id: week.id).find_each do |invoice|
        if invoice.team.is_validated && !invoice.team.is_gst && invoice.due > 0
          bsb = invoice.team.bsb
          bsb = bsb[0..2]+"-"+bsb[3..5]
          aba2.add_transaction(
            {
              bsb: bsb,
              account_number: invoice.team.account_number,
              amount: (invoice.due*100).to_i, # Amount in cents
              account_name: invoice.team.name,
              transaction_code: 53,
              lodgement_reference: "SIMPLY MAID", #gst add here
              name_of_remitter: "SIMPLY MAID"
            }
          )
        end
      end
      if aba2.valid?
        week.update_attributes(
          aba_file_no_gst: aba2.to_s,
          aba_created_at: Time.now
        )
        result[:success] = true
        result[:data_no_gst] = aba2.to_s
      else
        result[:success] = false
        result[:errors] = aba2.errors
      end
    end

    result
  end

  def process_payments
    week = self
    result = {
      success: false,
      message: ""
    }

    if week.payment_date <= Time.now + 4.days
      if week.is_processed
        result[:success] = false
        result[:message] = 'Week was already processed'
      else
        if !week.is_parsed
          week.parse
        end
        invoices = Invoice.includes(:team).where(week_id: week.id).where('due > ?', 0).all
        if invoices.count > 0
          # check if teams completed
          all_ok = true
          invoices.each do |invoice|
            if invoice.team.bsb.nil? && invoice.team.account_number.nil?
              all_ok = false
            end
          end
          if !all_ok
            # remind admins to update details
            User.where(is_admin: true).each do |user|
              InvoiceMailer.with(week: week, user: user).missing_team_details_email.deliver
            end
            result[:success] = false
            result[:message] = 'Not all teams have BSB and Account number details'
          else
            # invoices.each do |invoice|
            #   InvoiceMailer.with(invoice: invoice).invoice_email.deliver
            # end
            results = week.create_aba
            if results[:success]
              week.update_attributes(
                is_processed: true,
                processed_at: Time.now
              )
              User.where(is_admin: true).each do |user|
                InvoiceMailer.with(week: week, user: user).payments_processed_email.deliver
              end
              result[:success] = true
              result[:message] = 'Week was successfully processed'
            else
              User.where(is_admin: true).each do |user|
                InvoiceMailer.with(week: week, user: user).missing_team_details_email.deliver
              end
              result[:success] = false
              result[:message] = 'Internal error'
            end
          end
        else
          User.where(is_admin: true).each do |user|
            InvoiceMailer.with(week: week, user: user).no_payments_due_email.deliver
          end
          result[:success] = false
          result[:message] = 'Nothing to pay'
        end
      end
    else
      result[:success] = false
      result[:message] = 'Week payment date is in the future'
    end

    result
  end

  def self.test_p
    week = Week.find(19)
    week.process_payments
  end
end
