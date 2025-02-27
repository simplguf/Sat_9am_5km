# frozen_string_literal: true

class ClubsController < ApplicationController
  def index
    @clubs = Athlete.joins(:club).group(:club).order(count_clubs: :desc).count(:clubs)
  end

  def show
    @club = Club.find(params[:id])
    @count_results = Athlete.left_joins(:results).where(club: @club).group('athletes.id').count('results.id')
    @athletes = Athlete.where(club: @club).order(:name)
  end
end
