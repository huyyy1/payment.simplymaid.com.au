class TeamsController < ApplicationController

  before_action :authenticate_user!

  def index
    @teams = Team.all.page params[:page]
  end

  def show
    @team = Team.includes([:tags, :invoices]).find(params[:id])
    @total_due = 0
    @total_paid = 0
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to @team
    else
      render 'new'
    end
  end

  def allexport
    filename = "all-teams-#{Time.now.to_i}.xlsx"
    workbook = WriteXLSX.new("#{Rails.root}/tmp/#{filename}")

    @teams = Team.includes([:tags, :invoices]).order('name ASC').all

    worksheet = workbook.add_worksheet('Teams Data')
    bold = workbook.add_format
    bold.set_bold
    bold.set_shrink()

    normal = workbook.add_format
    normal.set_shrink()

    row = 0

    worksheet.write(row, 0, "Name", bold)
    worksheet.write(row, 1, "First Name", bold)
    worksheet.write(row, 2, "Last Name", bold)
    worksheet.write(row, 3, "Email", bold)
    worksheet.write(row, 4, "Is GST", bold)
    worksheet.write(row, 5, "ABN", bold)
    worksheet.write(row, 6, "Billing Name", bold)
    worksheet.write(row, 7, "Address", bold)
    worksheet.write(row, 8, "BSB", bold)
    worksheet.write(row, 9, "Account Number", bold)
    worksheet.write(row, 10, "Created At", bold)
    worksheet.write(row, 11, "Updated At", bold)
    worksheet.write(row, 12, "# Invoices", bold)
    worksheet.write(row, 13, "Total Due", bold)
    worksheet.write(row, 14, "Total Paid", bold)

    row = 1
    @teams.each do |team|
      total_due = 0.0
      total_paid = 0.0

      team.invoices.each do |invoice|
        total_due = total_due + invoice.due
        total_paid = total_paid + invoice.paid
      end

      if team.is_gst
        gst = "GST"
      else
        gst = "Non GST"
      end

      worksheet.write(row, 0, team.name, normal)
      worksheet.write(row, 1, "#{team.first_name}", normal)
      worksheet.write(row, 2, "#{team.last_name}", normal)
      worksheet.write(row, 3, team.email, normal)
      worksheet.write(row, 4, gst, normal)
      worksheet.write(row, 5, team.abn, normal)
      worksheet.write(row, 6, team.billing_name, normal)
      worksheet.write(row, 7, team.address, normal)
      worksheet.write(row, 8, team.bsb, normal)
      worksheet.write(row, 9, team.account_number, normal)
      worksheet.write(row, 10, team.created_at.strftime("%d/%m/%Y %H:%M"), normal)
      worksheet.write(row, 11, team.updated_at.strftime("%d/%m/%Y %H:%M"), normal)
      worksheet.write(row, 12, team.invoices.count, normal)
      worksheet.write(row, 13, total_due, normal)
      worksheet.write(row, 14, total_paid, normal)

      row = row + 1
    end

    workbook.close

    send_file("#{Rails.root}/tmp/#{filename}",
      :filename => filename,
      :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  def export
    @team = Team.includes(:tags).find(params[:id])
    filename = "#{@team.name}-#{Time.now.to_i}.xlsx"
    workbook = WriteXLSX.new("#{Rails.root}/tmp/#{filename}")

    worksheet = workbook.add_worksheet('Team Info')
    bold = workbook.add_format
    bold.set_bold
    bold.set_shrink()

    normal = workbook.add_format
    normal.set_shrink()

    row = 0
    worksheet.write(row, 0, "Name", bold)
    worksheet.write(row, 1, @team.name, normal)
    row = row + 1

    if @team.first_name.present?
      worksheet.write(row, 0, "First name", bold)
      worksheet.write(row, 1, @team.first_name, normal)
      row = row + 1
    end

    if @team.last_name.present?
      worksheet.write(row, 0, "Last name", bold)
      worksheet.write(row, 1, @team.last_name, normal)
      row = row + 1
    end

    worksheet.write(row, 0, "Email", bold)
    worksheet.write(row, 1, @team.email, normal)
    row = row + 1

    if @team.tags.count > 0
      tags = @team.tags.map(&:title).join(", ")
      worksheet.write(row, 0, "Tags", bold)
      worksheet.write(row, 1, tags, normal)
      row = row + 1
    end

    worksheet.write(row, 0, "GST Registered", bold)
    worksheet.write(row, 1, @team.is_gst ? "Yes" : "No", normal)
    row = row + 1

    worksheet.write(row, 0, "ABN", bold)
    worksheet.write_string(row, 1, @team.abn, normal)
    row = row + 1

    worksheet.write(row, 0, "Billing name", bold)
    worksheet.write(row, 1, @team.billing_name, normal)
    row = row + 1

    worksheet.write(row, 0, "Address", bold)
    worksheet.write(row, 1, @team.address, normal)
    row = row + 1

    worksheet.write(row, 0, "BSB", bold)
    worksheet.write_string(row, 1, @team.bsb, normal)
    row = row + 1

    worksheet.write(row, 0, "Account number", bold)
    worksheet.write_string(row, 1, @team.account_number, normal)
    row = row + 1

    worksheet.write(row, 0, "Created at", bold)
    worksheet.write(row, 1, @team.created_at.strftime("%d/%m/%Y %H:%M"), normal)
    row = row + 1

    worksheet.write(row, 0, "Last updated at", bold)
    worksheet.write(row, 1, @team.updated_at.strftime("%d/%m/%Y %H:%M"), normal)
    row = row + 1

    worksheet.write(row, 0, "Invoices delivery", bold)
    worksheet.write(row, 1, @team.unsubscribed ? "Unsubscribed" : "Email", normal)
    row = row + 1

    worksheet = workbook.add_worksheet('Invoices')
    row = 0

    worksheet.write(0, 0, "Dates", bold)
    worksheet.write(0, 1, "Due", bold)
    worksheet.write(0, 2, "Paid", bold)

    @invoices = Invoice.includes([:week, :team]).where(team_id: @team.id).order('week_id DESC').all

    @total_due = 0.0
    @total_paid = 0.0

    row = 1
    @invoices.each do |invoice|
      worksheet.write(row, 0, invoice.week.start_date.strftime("%d/%m/%Y")+" - "+invoice.week.end_date.strftime("%d/%m/%Y"), normal)
      worksheet.write(row, 1, ActionController::Base.helpers.number_to_currency(invoice.due), normal)
      worksheet.write(row, 2, ActionController::Base.helpers.number_to_currency(invoice.paid), normal)

      @total_due = @total_due + invoice.due
      @total_paid = @total_paid + invoice.paid
      row = row + 1
    end

    worksheet.write(row, 0, "Total", bold)
    worksheet.write(row, 1, ActionController::Base.helpers.number_to_currency(@total_due), bold)
    worksheet.write(row, 2, ActionController::Base.helpers.number_to_currency(@total_paid), bold)

    workbook.close

    send_file("#{Rails.root}/tmp/#{filename}",
      :filename => filename,
      :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  def edit
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])

    if @team.update(team_params)
      if params[:week_back].present?
        redirect_to week_path(params[:week_back]), notice: "Team updated"
      else
        redirect_to @team, notice: "Team updated"
      end
    else
      render 'edit'
    end
  end

  private

  def team_params
    params.require(:team).permit(
      :name,
      :first_name,
      :last_name,
      :status,
      :email,
      :is_gst,
      :abn,
      :billing_name,
      :address,
      :bsb,
      :account_number,
      :notes,
      :unsubscribed
    )
  end

end
