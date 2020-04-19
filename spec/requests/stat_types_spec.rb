# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'
require 'requests/requests_helper'

RSpec.describe 'Stats', type: :request do
  include_context :user
  include_context :headers

  before(:each) do
    login(user.name, user.password)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get '/stats', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(Stat::ALL.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/stats/averages', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(Stat.find_by(key: :averages).to_simple)
    end

    it 'returns not found for unknown stats' do
      get '/stats/143432332'
      expect(response).to have_http_status(:not_found)
    end
  end
end