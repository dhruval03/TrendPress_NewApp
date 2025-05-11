# Trend Press App

Trend Press is a modern news application built with Flutter, designed to deliver trending news articles to users. It integrates with a public news API and provides features like category filtering, search, and local storage for favorite articles. The app uses GetX for state management and navigation, ensuring a seamless user experience.

## Features

- **Home Screen**: Displays a list of trending news articles fetched from a public API.
- **Category Selection**: Allows users to filter news by categories such as Business, Sports, Tech, etc.
- **Search Feature**: Enables users to search for news articles by keyword.
- **News Details Page**: Opens a detailed view of a news article when clicked, including the title, image, content, and a link to the full article.
- **Favorites Section**: Users can save articles as favorites, which are stored locally using `SharedPreferences`, and view them in a dedicated section.
- **State Management**: Utilizes GetX for API calls, state handling, and navigation, ensuring efficient and scalable app architecture.

## API Integration

- **News API**: Fetches news articles from a public API, [NewsAPI.org](https://newsapi.org/), to display trending and category-specific news.


## Getting Started

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart**: Comes with Flutter
- **Node.js**: For the custom API endpoint ([Install Node.js](https://nodejs.org/))
- **A code editor**: (e.g., VS Code, Android Studio)
- **A NewsAPI.org API key**: [Get API Key](https://newsapi.org/register)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/dhruval03/TrendPress_NewApp
   cd TrendPress_NewApp
   
2. **Install Flutter Dependencies**:
    ```bash
    flutter pub get

3. **Setup .env**:
    ```bash
    NEWS_API_KEY=your_newsapi_key_here

3. **Run The App**:
    ```bash
    flutter run

## 📬 Contact

For any inquiries, please reach out to 📧 [maniyardhruval1290@gmail.com](mailto:maniyardhruval1290@gmail.com)  
or open an issue on [GitHub Issues](https://github.com/dhruval03/TrendPress_NewApp/issues)

