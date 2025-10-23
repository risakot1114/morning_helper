require 'rails_helper'

RSpec.describe 'Weekly Clothing API', type: :request do
  describe 'GET /api/v1/clothing/weekly' do
    context 'with valid parameters' do
      let(:valid_params) { { lat: 35.6762, lon: 139.6503, style: 'business' } }

      it 'returns weekly clothing suggestions successfully' do
        get '/api/v1/clothing/weekly', params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_present
        expect(json_response['data']['weekly_outfits']).to be_present
        expect(json_response['data']['weekly_summary']).to be_present
      end

      it 'includes required weekly clothing fields' do
        get '/api/v1/clothing/weekly', params: valid_params

        json_response = JSON.parse(response.body)
        weekly_outfits = json_response['data']['weekly_outfits']
        
        expect(weekly_outfits).to be_an(Array)
        expect(weekly_outfits.length).to be <= 7
        
        if weekly_outfits.any?
          first_day = weekly_outfits.first
          expect(first_day).to include('date', 'day_of_week', 'outfit', 'advice', 'laundry_suggestion')
          expect(first_day['outfit']).to include('top', 'bottom', 'shoes', 'style')
        end
      end

      it 'supports different styles' do
        styles = ['business', 'casual', 'child']
        
        styles.each do |style|
          get '/api/v1/clothing/weekly', params: valid_params.merge(style: style)
          
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['data']['style']).to eq(style)
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing coordinates' do
        get '/api/v1/clothing/weekly', params: { style: 'business' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
      end
    end
  end
end
