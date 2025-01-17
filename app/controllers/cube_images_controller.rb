# frozen_string_literal: true

require 'net/http'
require 'twisty_puzzles'
require 'cube_trainer/anki/cube_visualizer'

# Controller that generates and serves cube images.
class CubeImagesController < ApplicationController
  prepend_before_action :set_mode
  before_action :set_input
  before_action :set_transformation
  before_action :set_input_item
  before_action :set_cube_state

  # Get /trainer/1/cube_images/1/left.jpg
  def show
    @transformation.apply_to(@cube_state)
    send_data cube_visualizer.fetch(@cube_state), type: 'image/jpg', disposition: 'inline'
  end

  private

  FORMAT = :jpg
  ROTATE_LEFT = TwistyPuzzles::Algorithm.move(TwistyPuzzles::Rotation::LEFT)

  def set_mode
    @mode = current_user.modes.find(params[:mode_id])
  end

  def set_input
    @input = @mode.inputs.find(params[:input_id])
  end

  def set_transformation
    case params[:img_side]
    when 'left' then @transformation = ROTATE_LEFT
    when 'right' then @transformation = TwistyPuzzles::Algorithm::EMPTY
    else head(:bad_request)
    end
  end

  def set_input_item
    head :not_found unless (@input_item = fetch_input_item)
  end

  def owner
    @mode.user
  end

  def fetch_input_item
    # TODO: Make this efficient
    @mode.generator.input_items.find { |i| i.representation == @input.input_representation }
  end

  def set_cube_state
    head(:unprocessable_entity) unless (@cube_state = @input_item.cube_state)
  end

  def cube_visualizer
    CubeTrainer::Anki::CubeVisualizer.new(
      fetcher: Net::HTTP,
      sch: @mode.color_scheme.to_twisty_puzzles_color_scheme,
      cache: Rails.cache,
      fmt: FORMAT,
      checker: checker
    )
  end

  def checker
    CubeTrainer::Anki::ImageChecker.new(FORMAT)
  end
end
