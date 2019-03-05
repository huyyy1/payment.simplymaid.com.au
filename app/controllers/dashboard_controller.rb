class DashboardController < ApplicationController

  before_action :authenticate_user!

  def index
    redirect_to weeks_path
  end

end
