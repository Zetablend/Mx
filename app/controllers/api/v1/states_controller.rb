class Api::V1::StatesController < ApplicationController
    skip_before_action :authenticate_request, only: [ :update, :destroy, :index ,:create]
    before_action :set_state, only: [ :update, :destroy]

  def index
    states = State.all
    render json: states
  end

  def create
    state = State.new(state_params)
    if state.save
      render json: state, status: :created
    else
      render json: { errors: state.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @state.update(state_params)
      render json: @state
    else
      render json: { errors: @state.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @state.destroy
    head :no_content
  end

  private

  def set_state
    @state = State.find(params[:id])
  end

  def state_params
    params.require(:state).permit(:name)
  end
end
