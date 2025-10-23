require 'rails_helper'

RSpec.describe WeatherService do
  let(:service) { described_class.new(lat: 35.6762, lon: 139.6503) }

  describe '#current_weather' do
    context 'when API key is not set' do
      before do
        allow(ENV).to receive(:[]).with('OPENWEATHER_API_KEY').and_return(nil)
      end

      it 'returns demo data' do
        weather_data = service.current_weather
        
        expect(weather_data).to be_present
        expect(weather_data[:current]).to be_present
        expect(weather_data[:location]).to be_present
        expect(weather_data[:current][:temperature]).to be_a(Integer)
      end
    end

    context 'when API call fails' do
      before do
        allow(ENV).to receive(:[]).with('OPENWEATHER_API_KEY').and_return('test_key')
        allow(HTTParty).to receive(:get).and_raise(SocketError.new('Network error'))
      end

      it 'returns demo data as fallback' do
        weather_data = service.current_weather
        
        expect(weather_data).to be_present
        expect(weather_data[:current]).to be_present
      end
    end
  end

  describe '#determine_location_name' do
    it 'returns correct location for Tokyo coordinates' do
      location = service.send(:determine_location_name, 35.6762, 139.6503)
      expect(location).to include('東京都')
    end

    it 'returns correct location for Kawasaki coordinates' do
      location = service.send(:determine_location_name, 35.5, 139.7)
      expect(location).to include('川崎市')
    end

    it 'returns coordinates for unknown locations' do
      location = service.send(:determine_location_name, 0, 0)
      expect(location).to match(/緯度: 0, 経度: 0/)
    end
  end
end
