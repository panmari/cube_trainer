# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

describe ColorScheme, type: :model do
  include_context 'with user abc'

  it 'can be constructed from a TwistyPuzzles ColorScheme and back' do
    color_scheme = described_class.from_twisty_puzzles_color_scheme(TwistyPuzzles::ColorScheme::WCA)
    color_scheme.user = user
    expect(color_scheme).to be_valid
    expect(color_scheme.to_twisty_puzzles_color_scheme).to eq(TwistyPuzzles::ColorScheme::WCA)
  end
end
