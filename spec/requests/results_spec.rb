# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Results', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with input'
  include_context 'with result'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #index' do
    it 'returns http success' do
      Result.delete_all
      result
      get "/api/modes/#{mode.id}/results", params: { offset: 0, limit: 100 }, headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(result.id)
      expect(parsed_item['mode']).to eq_modulo_symbol_vs_string(mode.to_simple)
      expect(parsed_item['input_representation']).to eq(input.input_representation.to_s)
      expect(parsed_item['time_s']).to eq(10)
      expect(parsed_item['failed_attempts']).to eq(0)
      expect(parsed_item['success']).to eq(true)
      expect(parsed_item['num_hints']).to eq(0)
    end

    it 'returns not found for another user' do
      get "/api/modes/#{mode.id}/results", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/modes/#{mode.id}/results/#{result.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(result.id)
      expect(parsed_body['mode']).to eq_modulo_symbol_vs_string(mode.to_simple)
      expect(parsed_body['input_representation']).to eq(input.input_representation.to_s)
      expect(parsed_body['time_s']).to eq(10)
      expect(parsed_body['failed_attempts']).to eq(0)
      expect(parsed_body['success']).to eq(true)
      expect(parsed_body['num_hints']).to eq(0)
    end

    it 'returns not found for unknown results' do
      get "/api/modes/#{mode.id}/results/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/modes/#{mode.id}/results", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/modes/#{mode.id}/results/#{result.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      expect(Result.exists?(result.id)).to be(false)
    end

    it 'returns not found for unknown results' do
      delete "/api/modes/#{mode.id}/results/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      delete "/api/modes/#{mode.id}/results/#{result.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
      expect(Result.exists?(result.id)).to be(true)
    end
  end
end
