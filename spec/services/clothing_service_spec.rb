require 'rails_helper'

RSpec.describe ClothingService do
  let(:service) { described_class.new(temperature: 20, weather: 'clear', style: 'business') }

  describe '#suggest_outfit' do
    it 'returns outfit suggestion' do
      suggestion = service.suggest_outfit
      
      expect(suggestion).to be_present
      expect(suggestion[:outfit]).to be_present
      expect(suggestion[:advice]).to be_present
      expect(suggestion[:comfort_level]).to be_present
    end

    it 'includes required outfit fields' do
      suggestion = service.suggest_outfit
      outfit = suggestion[:outfit]
      
      expect(outfit).to include(:top, :bottom, :shoes, :style)
      expect(outfit[:style]).to eq('business')
    end

    context 'with different styles' do
      it 'returns business outfit' do
        business_service = described_class.new(temperature: 20, weather: 'clear', style: 'business')
        suggestion = business_service.suggest_outfit
        
        expect(suggestion[:outfit][:style]).to eq('business')
      end

      it 'returns casual outfit' do
        casual_service = described_class.new(temperature: 20, weather: 'clear', style: 'casual')
        suggestion = casual_service.suggest_outfit
        
        expect(suggestion[:outfit][:style]).to eq('casual')
      end

      it 'returns child outfit' do
        child_service = described_class.new(temperature: 20, weather: 'clear', style: 'child')
        suggestion = child_service.suggest_outfit
        
        expect(suggestion[:outfit][:style]).to eq('child')
      end
    end

    context 'with different temperatures' do
      it 'suggests warm clothes for cold weather' do
        cold_service = described_class.new(temperature: 5, weather: 'clear', style: 'business')
        suggestion = cold_service.suggest_outfit
        
        expect(suggestion[:outfit][:outer]).to be_present
      end

      it 'suggests light clothes for warm weather' do
        warm_service = described_class.new(temperature: 30, weather: 'clear', style: 'business')
        suggestion = warm_service.suggest_outfit
        
        expect(suggestion[:outfit][:outer]).to be_nil
      end
    end
  end
end
