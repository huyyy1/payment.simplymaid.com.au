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
      :notes
    )
  end

end
