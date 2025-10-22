import React, { useState, useEffect } from 'react';
import WeatherCard from './components/WeatherCard';
import ClothingCard from './components/ClothingCard';
import { apiService, WeatherResponse, ClothingResponse } from './services/api';
import './App.css';

interface Location {
  lat: number;
  lon: number;
}

function App() {
  const [weather, setWeather] = useState<WeatherResponse['data'] | null>(null);
  const [clothing, setClothing] = useState<ClothingResponse['data'] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [location, setLocation] = useState<Location | null>(null);

  // 位置情報を取得
  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setLocation({
            lat: position.coords.latitude,
            lon: position.coords.longitude,
          });
        },
        (error) => {
          console.error('位置情報の取得に失敗しました:', error);
          // デフォルトで東京の座標を使用
          setLocation({
            lat: 35.6762,
            lon: 139.6503,
          });
        }
      );
    } else {
      // デフォルトで東京の座標を使用
      setLocation({
        lat: 35.6762,
        lon: 139.6503,
      });
    }
  }, []);

  // データを取得
  useEffect(() => {
    const fetchData = async () => {
      if (!location) return;

      setLoading(true);
      setError(null);

      try {
        // 天気データを取得
        const weatherResponse = await apiService.getWeather(location.lat, location.lon);
        setWeather(weatherResponse.data);

        // 服装データを取得
        const clothingResponse = await apiService.getClothing(
          weatherResponse.data.current.temperature,
          weatherResponse.data.current.condition
        );
        setClothing(clothingResponse.data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'データの取得に失敗しました');
        console.error('データ取得エラー:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [location]);

  const handleRefresh = () => {
    if (location) {
      setLoading(true);
      setError(null);
      
      // データを再取得
      const fetchData = async () => {
        try {
          const weatherResponse = await apiService.getWeather(location.lat, location.lon);
          setWeather(weatherResponse.data);

          const clothingResponse = await apiService.getClothing(
            weatherResponse.data.current.temperature,
            weatherResponse.data.current.condition
          );
          setClothing(clothingResponse.data);
        } catch (err) {
          setError(err instanceof Error ? err.message : 'データの取得に失敗しました');
        } finally {
          setLoading(false);
        }
      };

      fetchData();
    }
  };

  return (
    <div className="min-h-screen p-4">
      {/* ヘッダー */}
      <div className="max-w-4xl mx-auto mb-8">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-white text-shadow mb-2">
            🌈 Morning Helper
          </h1>
          <p className="text-white/90 text-lg">
            朝の天気・服装・花粉・占いアプリ
          </p>
        </div>
      </div>

      {/* エラー表示 */}
      {error && (
        <div className="max-w-4xl mx-auto mb-6">
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-2xl">
            <div className="flex items-center">
              <span className="text-xl mr-2">⚠️</span>
              <span>{error}</span>
            </div>
          </div>
        </div>
      )}

      {/* メインコンテンツ */}
      <div className="max-w-4xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* 天気カード */}
          <div>
            {weather ? (
              <WeatherCard weather={weather} loading={loading} />
            ) : (
              <WeatherCard 
                weather={{
                  current: {
                    temperature: 0,
                    feels_like: 0,
                    condition: 'Loading...',
                    description: 'Loading...',
                    icon: '☁️',
                    humidity: 0,
                    wind_speed: 0,
                    uv_index: 0,
                  },
                  today: {
                    max_temp: 0,
                    min_temp: 0,
                    rain_probability: 0,
                    sunrise: '00:00',
                    sunset: '00:00',
                  },
                }} 
                loading={true} 
              />
            )}
          </div>

          {/* 服装カード */}
          <div>
            {clothing ? (
              <ClothingCard clothing={clothing} loading={loading} />
            ) : (
              <ClothingCard 
                clothing={{
                  outfit: {
                    top: '',
                    bottom: '',
                    outer: null,
                    shoes: '',
                    accessories: [],
                    icon: '👔',
                    style: 'business',
                  },
                  advice: 'Loading...',
                  comfort_level: 'moderate',
                  temperature_range: { min: 0, max: 0 },
                }} 
                loading={true} 
              />
            )}
          </div>
        </div>

        {/* リフレッシュボタン */}
        <div className="text-center mt-8">
          <button
            onClick={handleRefresh}
            disabled={loading}
            className="bg-white/90 hover:bg-white text-gray-800 font-bold py-3 px-6 rounded-2xl shadow-card transition-all duration-300 transform hover:-translate-y-1 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? '🔄 更新中...' : '🔄 更新'}
          </button>
        </div>
      </div>

      {/* フッター */}
      <div className="max-w-4xl mx-auto mt-12 text-center">
        <p className="text-white/70 text-sm">
          Made with ❤️ for your morning routine
        </p>
      </div>
    </div>
  );
}

export default App;
