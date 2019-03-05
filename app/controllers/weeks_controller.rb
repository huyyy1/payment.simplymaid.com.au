class WeeksController < ApplicationController

  before_action :authenticate_user!

  def index
    @weeks = Week.includes(:invoices).past.all
  end

  def show
    @week = Week.find(params[:id])
    @invoices = Invoice.not_empty.includes(:team).where(week_id: @week.id).all
  end

  def all
    @week = Week.find(params[:id])
    @invoices = Invoice.includes(:team).where(week_id: @week.id).page params[:page]
  end

  def aba_gst
    @week = Week.find(params[:id])
    if @week.aba_file_gst.present?
      send_data @week.aba_file_gst,
        filename: "payment_gst_#{@week.start_date.strftime('%d%m%Y')}_#{@week.end_date.strftime('%d%m%Y')}.aba",
        type: "text/*"
    else
      redirect_to week_path(@week.id), alert: "ABA file was not created yet"
    end
  end

  def aba_no_gst
    @week = Week.find(params[:id])
    if @week.aba_file_no_gst.present?
      send_data @week.aba_file_no_gst,
        filename: "payment_no_gst_#{@week.start_date.strftime('%d%m%Y')}_#{@week.end_date.strftime('%d%m%Y')}.aba",
        type: "text/*"
    else
      redirect_to week_path(@week.id), alert: "ABA file was not created yet"
    end
  end

  def parse
    @week = Week.find(params[:id])
    if !@week.is_processed
      if @week.payment_date > Time.now + 4.days
        redirect_to week_path(@week.id), alert: "Week is not ready for parsing"
      else
        @week.parse
        redirect_to week_path(@week.id), notice: "Week was parsed"
      end
    else
      redirect_to week_path(@week.id), alert: "Week is already processed"
    end
  end

  def process_payments
    if current_user.is_admin
      @week = Week.find(params[:id])
      result = @week.process_payments
      if result[:success]
        redirect_to week_path(@week.id), notice: result[:message]
      else
        redirect_to week_path(@week.id), alert: result[:message]
      end
    else
      redirect_to week_path(@week.id), alert: "No access"
    end
  end

end
