import React from 'react';

interface ClothingOutfit {
  top: string;
  bottom: string;
  outer: string | null;
  shoes: string;
  accessories: string[];
  icon: string;
  style: string;
}

interface ClothingData {
  outfit: ClothingOutfit;
  advice: string;
  comfort_level: string;
  temperature_range: {
    min: number;
    max: number;
  };
}

interface ClothingCardProps {
  clothing: ClothingData;
  loading?: boolean;
}

const ClothingCard: React.FC<ClothingCardProps> = ({ clothing, loading = false }) => {
  const getStyleColor = (style: string) => {
    switch (style) {
      case 'business': return 'bg-blue-100 text-blue-800';
      case 'casual': return 'bg-green-100 text-green-800';
      case 'child': return 'bg-pink-100 text-pink-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getComfortLevelColor = (level: string) => {
    switch (level) {
      case 'comfortable': return 'text-green-600';
      case 'moderate': return 'text-yellow-600';
      case 'uncomfortable': return 'text-red-600';
      default: return 'text-gray-600';
    }
  };

  if (loading) {
    return (
      <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-6 shadow-card border border-white/20">
        <div className="animate-pulse">
          <div className="h-6 bg-gray-200 rounded-lg mb-4"></div>
          <div className="h-8 bg-gray-200 rounded-lg mb-4"></div>
          <div className="space-y-3">
            <div className="h-4 bg-gray-200 rounded-lg"></div>
            <div className="h-4 bg-gray-200 rounded-lg"></div>
            <div className="h-4 bg-gray-200 rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-6 shadow-card border border-white/20 hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1">
      {/* ヘッダー */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold text-gray-800 text-shadow">👔 おすすめコーデ</h2>
        <div className="text-3xl">{clothing.outfit.icon}</div>
      </div>

      {/* スタイルバッジ */}
      <div className="flex justify-center mb-4">
        <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStyleColor(clothing.outfit.style)}`}>
          {clothing.outfit.style === 'business' ? 'ビジネス' : 
           clothing.outfit.style === 'casual' ? 'カジュアル' : 
           clothing.outfit.style === 'child' ? 'キッズ' : clothing.outfit.style}
        </span>
      </div>

      {/* コーディネート */}
      <div className="space-y-3 mb-6">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-morning-blue/20 rounded-full flex items-center justify-center">👕</div>
          <div className="flex-1">
            <div className="text-sm text-gray-600">トップス</div>
            <div className="font-medium text-gray-800">{clothing.outfit.top}</div>
          </div>
        </div>

        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-morning-green/20 rounded-full flex items-center justify-center">👖</div>
          <div className="flex-1">
            <div className="text-sm text-gray-600">ボトムス</div>
            <div className="font-medium text-gray-800">{clothing.outfit.bottom}</div>
          </div>
        </div>

        {clothing.outfit.outer && (
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-morning-purple/20 rounded-full flex items-center justify-center">🧥</div>
            <div className="flex-1">
              <div className="text-sm text-gray-600">アウター</div>
              <div className="font-medium text-gray-800">{clothing.outfit.outer}</div>
            </div>
          </div>
        )}

        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-morning-orange/20 rounded-full flex items-center justify-center">👟</div>
          <div className="flex-1">
            <div className="text-sm text-gray-600">シューズ</div>
            <div className="font-medium text-gray-800">{clothing.outfit.shoes}</div>
          </div>
        </div>

        {clothing.outfit.accessories.length > 0 && (
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-morning-pink/20 rounded-full flex items-center justify-center">💍</div>
            <div className="flex-1">
              <div className="text-sm text-gray-600">アクセサリー</div>
              <div className="font-medium text-gray-800">{clothing.outfit.accessories.join(', ')}</div>
            </div>
          </div>
        )}
      </div>

      {/* アドバイス */}
      <div className="bg-morning-mint/30 rounded-2xl p-3 mb-4">
        <div className="text-sm text-gray-700 text-center font-medium">
          💡 {clothing.advice}
        </div>
      </div>

      {/* 快適度と気温範囲 */}
      <div className="flex justify-between items-center text-sm">
        <div className={`font-medium ${getComfortLevelColor(clothing.comfort_level)}`}>
          {clothing.comfort_level === 'comfortable' ? '😊 快適' :
           clothing.comfort_level === 'moderate' ? '😐 普通' :
           clothing.comfort_level === 'uncomfortable' ? '😰 不快' : clothing.comfort_level}
        </div>
        <div className="text-gray-600">
          {clothing.temperature_range.min}°C - {clothing.temperature_range.max}°C
        </div>
      </div>
    </div>
  );
};

export default ClothingCard;
