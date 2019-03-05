class Invoice < ApplicationRecord
  belongs_to :week
  belongs_to :team

  scope :not_empty, -> { where('due > ?',0) }

  def generate_pdf
    invoice = self
    string = ApplicationController.new.render_to_string(
      template: 'invoices/show.pdf.erb',
      layout: nil,
      locals: { invoice: invoice }
    )
    pdf = WickedPdf.new.pdf_from_string(
      string,
      dpi: "300"
    )
    pdf
  end
end
