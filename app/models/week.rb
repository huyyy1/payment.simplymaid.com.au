class Week < ApplicationRecord
  has_many :invoices
  has_many :teams, through: :invoices

  def parse
    # "alex.shkolnikov@gmail.com"
    # "bozqiv-duwwoc-fybzA4"

    week = self

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

        sleep 1
        page += 1
      end
      week.update_columns(
        is_parsed: true,
        parsed_at: Time.now
      )
    end
  end

  def self.test_parse
    w = Week.find(11)
    w.parse
  end
end
