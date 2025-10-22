const API_BASE_URL = 'http://localhost:3000/api/v1';

export interface WeatherResponse {
  status: string;
  data: {
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
  };
  message: string;
  timestamp: string;
}

export interface ClothingResponse {
  status: string;
  data: {
    outfit: {
      top: string;
      bottom: string;
      outer: string | null;
      shoes: string;
      accessories: string[];
      icon: string;
      style: string;
    };
    advice: string;
    comfort_level: string;
    temperature_range: {
      min: number;
      max: number;
    };
  };
  message: string;
  timestamp: string;
}

export interface ApiError {
  status: string;
  error: {
    code: string;
    message: string;
  };
  timestamp: string;
}

class ApiService {
  private async request<T>(endpoint: string, params?: Record<string, string>): Promise<T> {
    const url = new URL(`${API_BASE_URL}${endpoint}`);
    
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.append(key, value);
      });
    }

    try {
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error?.message || 'API request failed');
      }

      return data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  async getWeather(lat: number, lon: number): Promise<WeatherResponse> {
    return this.request<WeatherResponse>('/weather', {
      lat: lat.toString(),
      lon: lon.toString(),
    });
  }

  async getClothing(temperature: number, weather: string): Promise<ClothingResponse> {
    return this.request<ClothingResponse>('/clothing', {
      temperature: temperature.toString(),
      weather: weather,
    });
  }
}

export const apiService = new ApiService();
