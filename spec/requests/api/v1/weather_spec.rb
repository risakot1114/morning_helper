require 'rails_helper'

RSpec.describe 'Weather API', type: :request do
  describe 'GET /api/v1/weather' do
    context 'with valid parameters' do
      let(:valid_params) { { lat: 35.6762, lon: 139.6503 } }

      it 'returns weather data successfully' do
        get '/api/v1/weather', params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_present
        expect(json_response['data']['current']).to be_present
        expect(json_response['data']['location']).to be_present
      end

      it 'includes required weather fields' do
        get '/api/v1/weather', params: valid_params

        json_response = JSON.parse(response.body)
        weather_data = json_response['data']['current']
        
        expect(weather_data).to include('temperature', 'condition', 'description', 'icon')
        expect(weather_data['temperature']).to be_a(Integer)
        expect(weather_data['condition']).to be_a(String)
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing latitude' do
        get '/api/v1/weather', params: { lon: 139.6503 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']['code']).to eq('INVALID_PARAMETERS')
      end

      it 'returns error for invalid latitude range' do
        get '/api/v1/weather', params: { lat: 200, lon: 139.6503 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
      end
    end
  end
end
