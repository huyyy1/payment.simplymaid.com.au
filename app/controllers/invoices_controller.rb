class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @invoice = Invoice.includes([:week, :team]).find(params[:id])
    respond_to do |format|
      format.pdf do
        render pdf: "#Receipt - {@invoice.team.name} {@invoice.week.payment_date('%Y.%m.%d')}", dpi: "300"
      end
    end
  end
end
