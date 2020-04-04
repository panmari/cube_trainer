class ModesController < ApplicationController
  before_action :get_mode, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_is_current_user, only: [:show, :edit, :update, :destroy]

  # GET /modes
  # GET /modes.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: current_user.modes, status: :ok }
    end
  end

  # GET /modes/1
  # GET /modes/1.json
  def show
  end

  # GET /modes/new
  def new
    @mode = current_user.modes.new
  end

  # GET /modes/1/edit
  def edit
  end

  # POST /modes
  # POST /modes.json
  def create
    @mode = current_user.modes.new(mode_params)
    logger.info @mode.inspect

    respond_to do |format|
      if @mode.save
        format.html { redirect_to @mode, notice: 'Mode was successfully created.' }
        format.json { render :show, status: :created, location: @mode }
      else
        format.html { render :new }
        format.json { render json: @mode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /modes/1
  # PATCH/PUT /modes/1.json
  def update
    respond_to do |format|
      if @mode.update(mode_params)
        format.html { redirect_to @mode, notice: 'Mode was successfully updated.' }
        format.json { render :show, status: :ok, location: @mode }
      else
        format.html { render :edit }
        format.json { render json: @mode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /modes/1
  # DELETE /modes/1.json
  def destroy
    @mode.destroy
    respond_to do |format|
      format.html { redirect_to modes_url, notice: 'Mode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def get_mode
    @mode ||= Mode.find(params[:id])
  end

  def get_owner
    get_mode.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params.require(:mode).permit(:name, :known, :mode_type, :show_input_mode, :buffer, :goal_badness, :cube_size)
  end
end
