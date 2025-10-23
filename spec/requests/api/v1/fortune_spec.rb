require 'rails_helper'

RSpec.describe 'Fortune API', type: :request do
  describe 'GET /api/v1/fortune' do
    context 'with valid parameters' do
      let(:valid_params) { { lat: 35.6762, lon: 139.6503, zodiac: 'aries' } }

      it 'returns fortune data successfully' do
        get '/api/v1/fortune', params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_present
        expect(json_response['data']['scores']).to be_present
        expect(json_response['data']['messages']).to be_present
      end

      it 'includes required fortune fields' do
        get '/api/v1/fortune', params: valid_params

        json_response = JSON.parse(response.body)
        fortune_data = json_response['data']
        
        expect(fortune_data).to include('overall_level', 'scores', 'messages', 'lucky_color', 'lucky_item')
        expect(fortune_data['scores']).to include('luck', 'love', 'work', 'health')
        
        # スコアが0-100の範囲内であることを確認
        fortune_data['scores'].each do |category, score|
          expect(score).to be_between(0, 100)
        end
      end

      it 'supports different zodiac signs' do
        zodiac_signs = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 
                       'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
        
        zodiac_signs.each do |zodiac|
          get '/api/v1/fortune', params: valid_params.merge(zodiac: zodiac)
          
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expect(json_response['data']).to be_present
        end
      end

      it 'works without zodiac parameter' do
        get '/api/v1/fortune', params: { lat: 35.6762, lon: 139.6503 }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing coordinates' do
        get '/api/v1/fortune', params: { zodiac: 'aries' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
      end
    end
  end
end
