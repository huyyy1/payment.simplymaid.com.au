class InvoiceMailer < ApplicationMailer

  def test_mail
    mail(to: 'alex.shkolnikov@gmail.com', subject: "SimplyMaid test")
  end

  def missing_team_details_email
    @week = params[:week]
    @user = params[:user]
    mail(to: @user.email, subject: "SimplyMaid: #{@week.start_date.strftime('%-d %B %Y')} to #{@week.end_date.strftime('%-d %B %Y')}: Processing error")
  end

  def aba_error_email
    @week = params[:week]
    @user = params[:user]
    @meta = params[:meta]
    mail(to: @user.email, subject: "SimplyMaid: #{@week.start_date.strftime('%-d %B %Y')} to #{@week.end_date.strftime('%-d %B %Y')}: ABA Error")
  end

  def no_payments_due_email
    @week = params[:week]
    @user = params[:user]
    mail(to: @user.email, subject: "SimplyMaid: #{@week.start_date.strftime('%-d %B %Y')} to #{@week.end_date.strftime('%-d %B %Y')}: No payments due")
  end

  def payments_processed_email
    @week = params[:week]
    @user = params[:user]

    if @week.aba_file_no_gst.present?
      attachments["payment_no_gst_#{@week.start_date.strftime('%d%m%Y')}_#{@week.end_date.strftime('%d%m%Y')}.aba"] = {
        mime_type: 'text/*',
        content: @week.aba_file_no_gst
      }
    end
    if @week.aba_file_gst.present?
      attachments["payment_gst_#{@week.start_date.strftime('%d%m%Y')}_#{@week.end_date.strftime('%d%m%Y')}.aba"] = {
        mime_type: 'text/*',
        content: @week.aba_file_gst
      }
    end

    mail(to: @user.email, subject: "SimplyMaid: Processing report for week: #{@week.start_date.strftime('%-d %B %Y')} to #{@week.end_date.strftime('%-d %B %Y')}")
  end

  def invoice_email
    @invoice = params[:invoice]

    attachments["invoice_#{@invoice.week.start_date.strftime('%d%m%Y')}_#{@invoice.week.end_date.strftime('%d%m%Y')}.pdf"] = {
      mime_type: 'application/pdf',
      content: @invoice.generate_pdf
    }

    mail(to: @invoice.team.email, subject: "SimplyMaid: Invoice for period from #{@invoice.week.start_date.strftime('%-d %B %Y')} to #{@invoice.week.end_date.strftime('%-d %B %Y')}")
  end

  def invoice_email_due
    @invoice = params[:invoice]

    attachments["invoice_#{@invoice.week.start_date.strftime('%d%m%Y')}_#{@invoice.week.end_date.strftime('%d%m%Y')}.pdf"] = {
      mime_type: 'application/pdf',
      content: @invoice.generate_pdf_due
    }

    mail(to: @invoice.team.email, subject: "SimplyMaid: Invoice for period from #{@invoice.week.start_date.strftime('%-d %B %Y')} to #{@invoice.week.end_date.strftime('%-d %B %Y')}")
  end

  def invoice_email_paid
    @invoice = params[:invoice]

    attachments["invoice_#{@invoice.week.start_date.strftime('%d%m%Y')}_#{@invoice.week.end_date.strftime('%d%m%Y')}.pdf"] = {
      mime_type: 'application/pdf',
      content: @invoice.generate_pdf_paid
    }

    mail(to: @invoice.team.email, subject: "SimplyMaid: Invoice for period from #{@invoice.week.start_date.strftime('%-d %B %Y')} to #{@invoice.week.end_date.strftime('%-d %B %Y')}")
  end

end
