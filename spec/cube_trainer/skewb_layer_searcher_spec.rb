# frozen_string_literal: true

require 'cube_trainer/skewb_layer_searcher'
require 'twisty_puzzles'
require 'set'

describe SkewbLayerSearcher do
  let(:verbose) { false }
  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }

  def verify_zero_move_algs(zero_move_algs)
    expect(zero_move_algs).to be == [TwistyPuzzles::Algorithm.empty]
  end

  def verify_one_move_algs(one_move_algs)
    expect(one_move_algs.length).to be == 1
    one_move_alg = one_move_algs[0]
    expect(one_move_alg.length).to be == 1
    expect(one_move_alg.moves.first).to be_a(TwistyPuzzles::SkewbMove)
  end

  def verify_two_move_algss(one_move_algs, two_move_algss)
    one_move_alg = one_move_algs[0]
    first_moves = Set[]
    two_move_algss.each do |two_move_algs|
      expect(two_move_algs.length).to be == 1
      two_move_alg = two_move_algs[0]
      expect(two_move_alg.length).to be == 2
      expect(two_move_alg.moves.last).to be == one_move_alg.moves.first
      expect(first_moves).to be_add(two_move_alg.moves.first)
    end
  end

  it 'finds all 0 move layers' do
    algss = described_class.calculate(color_scheme, verbose, 0)

    expect(algss.length).to be == 1
    verify_zero_move_algs(algss[0])
  end

  it 'finds all 0-1 move layers' do
    algss = described_class.calculate(color_scheme, verbose, 1)

    expect(algss.length).to be == 2
    verify_zero_move_algs(algss[0])
    verify_one_move_algs(algss[1])
  end

  it 'finds all 0-2 move layers' do
    algss = described_class.calculate(color_scheme, verbose, 2)

    expect(algss.length).to be == 8
    verify_zero_move_algs(algss[0])
    verify_one_move_algs(algss[1])
    verify_two_move_algss(algss[1], algss[2..7])
  end
end
