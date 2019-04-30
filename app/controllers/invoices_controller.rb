class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    respond_to do |format|
      format.pdf do
        render pdf: "#Receipt - {@invoice.team.name} {@invoice.week.payment_date('%Y.%m.%d')}", dpi: "1200"
      end
    end
  end

  def invoice_due
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    if @invoice.due <= 0
      redirect_back(fallback_location: week_path(@invoice.week_id))
    end
    respond_to do |format|
      format.pdf do
        render pdf: "#Receipt - {@invoice.team.name} {@invoice.week.payment_date('%Y.%m.%d')}", dpi: "1200"
      end
    end
  end

  def invoice_paid
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    if @invoice.paid <= 0
      redirect_back(fallback_location: week_path(@invoice.week_id))
    end
    respond_to do |format|
      format.pdf do
        render pdf: "#Receipt - {@invoice.team.name} {@invoice.week.payment_date('%Y.%m.%d')}", dpi: "1200"
      end
    end
  end

  def invoice_due_mail
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    if @invoice.due > 0 && current_user.is_admin
      InvoiceMailer.with(invoice: @invoice).invoice_email_due.deliver_later
      @invoice.update_columns(
        due_receipt_sent: true,
        due_receipt_sent_at: Time.now
      )
    end
    redirect_back(fallback_location: week_path(@invoice.week_id))
  end

  def invoice_paid_mail
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    if @invoice.paid > 0 && current_user.is_admin
      InvoiceMailer.with(invoice: @invoice).invoice_email_paid.deliver_later
      @invoice.update_columns(
        paid_receipt_sent: true,
        paid_receipt_sent_at: Time.now
      )
    end
    redirect_back(fallback_location: week_path(@invoice.week_id))
  end
end
