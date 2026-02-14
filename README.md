# 🌩️ vWeather (Vaxp Weather)

**vWeather** is a high-performance, professional-grade weather dashboard built for Linux using Flutter. It features a stunning glassmorphic UI, cinematic animations, and deep integration with the Venom desktop environment ecosystem.

## ✨ Key Features

### 🎨 Cinematic User Interface
*   **Glassmorphism**: Advanced transparent panels and blur effects that blend seamlessly with your desktop.
*   **Dynamic Animations**: Smooth, cinematic entry animations for all elements.
*   **Interactive Charts**: Beautiful spline charts for hourly temperature trends.

### 🌍 Smart Location Services
*   **Auto-Detection**: Automatically detects your location on startup using:
    *   **System Timezone** (Linux Native)
    *   **IP Geolocation** (Fallback)
*   **Advanced Search**: Instantly search for cities globally with "City, Country" precision.

### 📊 Rich Weather Data
Powered by the [Open-Meteo API](https://open-meteo.com/) (No API Key required!):
*   **Real-time Conditions**: Temperature, Feels Like, Weather Code.
*   **Detailed Metrics**: UV Index, Humidity, Wind Speed, Visibility, Sunset Time.
*   **Forecasts**:
    *   24-Hour Hourly Trend Line.
    *   7-Day Daily Forecast.

### 🐧 Linux Native Integration
*   **System Theming**: fully respects the `settings.vaxp` configuration for background colors and text styles.
*   **Window Controls**: Custom-drawn, integrated window controls (Minimize, Maximize, Close).

## .🛠️ Tech Stack using Vaxp Template
*   **Framework**: Flutter (Linux Desktop)
*   **State Management**: `flutter_bloc` (Clean Architecture)
*   **Data**: `http` (Open-Meteo)
*   **UI Components**: `flutter_animate`, `fl_chart`, `venom_config`

## 🚀 Getting Started

1.  **Clone the repository**
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run on Linux**:
    ```bash
    flutter run -d linux
    ```

## 📝 License
Proprietary / Vaxp Team.
