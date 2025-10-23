require 'rails_helper'

RSpec.describe 'Clothing API', type: :request do
  describe 'GET /api/v1/clothing' do
    context 'with valid parameters' do
      let(:valid_params) { { temperature: 20, weather: 'clear', style: 'business' } }

      it 'returns clothing suggestion successfully' do
        get '/api/v1/clothing', params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_present
        expect(json_response['data']['outfit']).to be_present
        expect(json_response['data']['advice']).to be_present
      end

      it 'includes required clothing fields' do
        get '/api/v1/clothing', params: valid_params

        json_response = JSON.parse(response.body)
        outfit_data = json_response['data']['outfit']
        
        expect(outfit_data).to include('top', 'bottom', 'shoes', 'style')
        expect(outfit_data['style']).to eq('business')
      end

      it 'supports different styles' do
        styles = ['business', 'casual', 'child']
        
        styles.each do |style|
          get '/api/v1/clothing', params: valid_params.merge(style: style)
          
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['data']['outfit']['style']).to eq(style)
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing temperature' do
        get '/api/v1/clothing', params: { weather: 'clear', style: 'business' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
      end
    end
  end
end
