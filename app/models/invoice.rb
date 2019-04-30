class Invoice < ApplicationRecord
  belongs_to :week
  belongs_to :team

  scope :not_empty, -> { where('due > ? or paid > ?',0,0) }
  scope :not_empty_due, -> { where('due > ?',0) }

  def generate_pdf
    invoice = self
    string = ApplicationController.new.render_to_string(
      template: 'invoices/show.pdf.erb',
      layout: nil,
      locals: { invoice: invoice }
    )
    pdf = WickedPdf.new.pdf_from_string(
      string,
      dpi: "1200"
    )
    pdf
  end

  def generate_pdf_due
    invoice = self
    string = ApplicationController.new.render_to_string(
      template: 'invoices/show_v2.pdf.erb',
      layout: nil,
      locals: { invoice: invoice, mode: "due" }
    )
    pdf = WickedPdf.new.pdf_from_string(
      string,
      dpi: "1200"
    )
    pdf
  end

  def generate_pdf_paid
    invoice = self
    string = ApplicationController.new.render_to_string(
      template: 'invoices/show_v2.pdf.erb',
      layout: nil,
      locals: { invoice: invoice, mode: "paid" }
    )
    pdf = WickedPdf.new.pdf_from_string(
      string,
      dpi: "1200"
    )
    pdf
  end
end
