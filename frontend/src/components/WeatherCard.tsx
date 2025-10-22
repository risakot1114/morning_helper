import React from 'react';

interface WeatherData {
  current: {
    temperature: number;
    feels_like: number;
    condition: string;
    description: string;
    icon: string;
    humidity: number;
    wind_speed: number;
    uv_index: number;
  };
  today: {
    max_temp: number;
    min_temp: number;
    rain_probability: number;
    sunrise: string;
    sunset: string;
  };
}

interface WeatherCardProps {
  weather: WeatherData;
  loading?: boolean;
}

const WeatherCard: React.FC<WeatherCardProps> = ({ weather, loading = false }) => {
  const getWeatherIcon = (condition: string) => {
    const conditionLower = condition.toLowerCase();
    if (conditionLower.includes('sunny') || conditionLower.includes('clear')) return '☀️';
    if (conditionLower.includes('cloud')) return '☁️';
    if (conditionLower.includes('rain')) return '🌧️';
    if (conditionLower.includes('snow')) return '❄️';
    if (conditionLower.includes('storm')) return '⛈️';
    if (conditionLower.includes('fog')) return '🌫️';
    return '🌤️';
  };

  const getTemperatureColor = (temp: number) => {
    if (temp >= 30) return 'text-red-500';
    if (temp >= 25) return 'text-orange-500';
    if (temp >= 20) return 'text-yellow-500';
    if (temp >= 15) return 'text-green-500';
    if (temp >= 10) return 'text-blue-500';
    return 'text-purple-500';
  };

  if (loading) {
    return (
      <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-6 shadow-card border border-white/20">
        <div className="animate-pulse">
          <div className="h-6 bg-gray-200 rounded-lg mb-4"></div>
          <div className="h-12 bg-gray-200 rounded-lg mb-4"></div>
          <div className="h-4 bg-gray-200 rounded-lg mb-2"></div>
          <div className="h-4 bg-gray-200 rounded-lg"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white/90 backdrop-blur-sm rounded-3xl p-6 shadow-card border border-white/20 hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1">
      {/* ヘッダー */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold text-gray-800 text-shadow">🌤️ 今日の天気</h2>
        <div className="text-3xl">{weather.current.icon}</div>
      </div>

      {/* メイン情報 */}
      <div className="text-center mb-6">
        <div className={`text-5xl font-bold ${getTemperatureColor(weather.current.temperature)} mb-2`}>
          {weather.current.temperature}°
        </div>
        <div className="text-lg text-gray-600 font-medium">{weather.current.description}</div>
        <div className="text-sm text-gray-500">体感: {weather.current.feels_like}°</div>
      </div>

      {/* 詳細情報 */}
      <div className="grid grid-cols-2 gap-4 mb-4">
        <div className="bg-morning-blue/20 rounded-2xl p-3 text-center">
          <div className="text-2xl mb-1">💧</div>
          <div className="text-sm text-gray-600">湿度</div>
          <div className="font-bold text-gray-800">{weather.current.humidity}%</div>
        </div>
        <div className="bg-morning-green/20 rounded-2xl p-3 text-center">
          <div className="text-2xl mb-1">💨</div>
          <div className="text-sm text-gray-600">風速</div>
          <div className="font-bold text-gray-800">{weather.current.wind_speed}m/s</div>
        </div>
      </div>

      {/* 今日の気温範囲 */}
      <div className="grid grid-cols-2 gap-4 mb-4">
        <div className="bg-morning-orange/20 rounded-2xl p-3 text-center">
          <div className="text-2xl mb-1">🌡️</div>
          <div className="text-sm text-gray-600">最高気温</div>
          <div className="font-bold text-gray-800">{weather.today.max_temp}°</div>
        </div>
        <div className="bg-morning-purple/20 rounded-2xl p-3 text-center">
          <div className="text-2xl mb-1">🌡️</div>
          <div className="text-sm text-gray-600">最低気温</div>
          <div className="font-bold text-gray-800">{weather.today.min_temp}°</div>
        </div>
      </div>

      {/* アドバイス */}
      <div className="mt-4 p-3 bg-morning-yellow/30 rounded-2xl">
        <div className="text-sm text-gray-700 text-center">
          {weather.current.temperature >= 25 && "☀️ 暑い日です！水分補給を忘れずに"}
          {weather.current.temperature < 25 && weather.current.temperature >= 15 && "🌤️ 快適な気温です"}
          {weather.current.temperature < 15 && "🧥 少し肌寒いです。上着をお忘れなく"}
        </div>
      </div>
    </div>
  );
};

export default WeatherCard;
