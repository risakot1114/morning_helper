require 'rails_helper'

RSpec.describe 'Weekly Weather API', type: :request do
  describe 'GET /api/v1/weather/weekly' do
    context 'with valid parameters' do
      let(:valid_params) { { lat: 35.6762, lon: 139.6503 } }

      it 'returns weekly weather data successfully' do
        get '/api/v1/weather/weekly', params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_present
        expect(json_response['data']['weekly_forecast']).to be_present
        expect(json_response['data']['location']).to be_present
      end

      it 'includes required weekly weather fields' do
        get '/api/v1/weather/weekly', params: valid_params

        json_response = JSON.parse(response.body)
        weekly_data = json_response['data']['weekly_forecast']
        
        expect(weekly_data).to be_an(Array)
        expect(weekly_data.length).to be <= 7
        
        if weekly_data.any?
          first_day = weekly_data.first
          expect(first_day).to include('date', 'day_of_week', 'max_temp', 'min_temp', 'condition', 'icon')
          expect(first_day['max_temp']).to be_a(Integer)
          expect(first_day['min_temp']).to be_a(Integer)
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing latitude' do
        get '/api/v1/weather/weekly', params: { lon: 139.6503 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['error']['code']).to eq('INVALID_PARAMETERS')
      end
    end
  end
end
