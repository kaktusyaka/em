class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def contact_us
    @contact_us = ContactUs.new
  end

  def contact_us_submit
    @contact_us = ContactUs.new(params.require(:contact_us).permit!)
    @contact_us[:ip_address] = request.remote_ip
    if verify_recaptcha(model: @contact_us) && @contact_us.save
      flash[:success] = 'Message has been sent! We will contact you as soon as possible!'
      redirect_to action: :contact_us
    else
      render action: :contact_us
    end
  end
end
