class Api::RichactionsController < ApplicationController
  def index
  end

  def create
    richactions = params[:richactions]
    richaction_ids = []
    richactions.each do |action|
      @richaction = Richaction.new

      @richaction[:x] = action[:x]
      @richaction[:y] = action[:y]
      @richaction[:width] = action[:width]
      @richaction[:height] = action[:height]
      @richaction[:richaction_type] = action[:type]
      @richaction[:text] = action[:text]
      @richaction[:uri] = action[:uri]
      @richaction[:data] = action[:data]

      @richaction.save
      richaction_ids.push(@richaction.id)
    end
    render json: richaction_ids, status: :ok
  end

  def show
  end

  private

  def richactions_params
    params.permit(
      richactions: [:x,:y,:width,:height,:type,:text,:uri,:data]
      )
  end
end