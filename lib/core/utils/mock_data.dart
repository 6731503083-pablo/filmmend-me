/// Centralized mock movie data for development & testing.
/// Replace with real API calls (e.g. TMDB) in production.
class MockData {
  MockData._();

  static const List<Map<String, dynamic>> movies = [
    {
      'id': '1',
      'title': 'Inception',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'rating': 8.8,
      'year': '2010',
      'rating_label': 'PG-13',
      'runtime': '2h 28m',
      'genres': ['Sci-Fi', 'Action', 'Thriller'],
      'synopsis':
          'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O. Dom Cobb is a skilled thief, the absolute best in the dangerous art of extraction, stealing valuable secrets from deep within the subconscious during the dream state, when the mind is at its most vulnerable.',
      'director': 'Christopher Nolan',
      'cast': 'Leonardo DiCaprio, Joseph Gordon-Levitt, Elliot Page',
    },
    {
      'id': '2',
      'title': 'The Grand Budapest Hotel',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/eWdyYQreja6JGCzqHWXpWHDrrPo.jpg',
      'rating': 8.1,
      'year': '2014',
      'rating_label': 'R',
      'runtime': '1h 40m',
      'genres': ['Comedy', 'Drama', 'Adventure'],
      'synopsis':
          'The adventures of Gustave H, a legendary concierge at a famous hotel from the fictional Republic of Zubrowka between the first and second World Wars, and Zero Moustafa, the lobby boy who becomes his most trusted friend.',
      'director': 'Wes Anderson',
      'cast': 'Ralph Fiennes, F. Murray Abraham, Mathieu Amalric',
    },
    {
      'id': '3',
      'title': 'Blade Runner 2049',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
      'rating': 8.0,
      'year': '2017',
      'rating_label': 'R',
      'runtime': '2h 44m',
      'genres': ['Sci-Fi', 'Mystery', 'Thriller'],
      'synopsis':
          'Thirty years after the events of the first film, a new blade runner, LAPD Officer K, unearths a long-buried secret that has the potential to plunge what\'s left of society into chaos. K\'s discovery leads him on a quest to find Rick Deckard, a former blade runner who has been missing for 30 years.',
      'director': 'Denis Villeneuve',
      'cast': 'Ryan Gosling, Harrison Ford, Ana de Armas',
    },
    {
      'id': '4',
      'title': 'Her',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/eCOtqtfvn7mxGl6nfmq4b1exJRc.jpg',
      'rating': 8.0,
      'year': '2013',
      'rating_label': 'R',
      'runtime': '2h 06m',
      'genres': ['Romance', 'Sci-Fi', 'Drama'],
      'synopsis':
          'In a near future Los Angeles, Theodore Twombly, a complex, soulful man who makes his living writing touching, personal letters for other people. Heartbroken after the end of a long relationship, he becomes intrigued with a new, advanced operating system, which promises to be an intuitive entity in its own right.',
      'director': 'Spike Jonze',
      'cast': 'Joaquin Phoenix, Amy Adams, Scarlett Johansson',
    },
    {
      'id': '5',
      'title': 'Parasite',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      'rating': 8.5,
      'year': '2019',
      'rating_label': 'R',
      'runtime': '2h 12m',
      'genres': ['Thriller', 'Drama', 'Comedy'],
      'synopsis':
          'All unemployed, Ki-taek and his family take peculiar interest in the wealthy and glamorous Parks, as they ingratiate themselves into their lives and get entangled in an unexpected incident.',
      'director': 'Bong Joon-ho',
      'cast': 'Song Kang-ho, Lee Sun-kyun, Cho Yeo-jeong',
    },
    {
      'id': '6',
      'title': 'Interstellar',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'rating': 8.7,
      'year': '2014',
      'rating_label': 'PG-13',
      'runtime': '2h 49m',
      'genres': ['Sci-Fi', 'Adventure', 'Drama'],
      'synopsis':
          'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
      'director': 'Christopher Nolan',
      'cast': 'Matthew McConaughey, Anne Hathaway, Jessica Chastain',
    },
    {
      'id': '7',
      'title': 'The Shawshank Redemption',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg',
      'rating': 9.3,
      'year': '1994',
      'rating_label': 'R',
      'runtime': '2h 22m',
      'genres': ['Drama', 'Crime'],
      'synopsis':
          'Over the course of several years, two convicts form a friendship, seeking consolation and, eventually, redemption through basic compassion.',
      'director': 'Frank Darabont',
      'cast': 'Tim Robbins, Morgan Freeman, Bob Gunton',
    },
    {
      'id': '8',
      'title': 'Spirited Away',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
      'rating': 8.6,
      'year': '2001',
      'rating_label': 'PG',
      'runtime': '2h 05m',
      'genres': ['Animation', 'Fantasy', 'Family'],
      'synopsis':
          'During her family\'s move to the suburbs, a sullen 10-year-old girl wanders into a world ruled by gods, witches, and spirits, and where humans are changed into beasts.',
      'director': 'Hayao Miyazaki',
      'cast': 'Rumi Hiiragi, Miyu Irino, Mari Natsuki',
    },
  ];

  /// Get a single movie by ID, or return a "not found" placeholder.
  static Map<String, dynamic> getMovieById(String id) {
    return movies.firstWhere(
      (m) => m['id'] == id,
      orElse: () => const {
        'id': '0',
        'title': 'Movie Not Found',
        'posterUrl': '',
        'rating': 0.0,
        'year': '',
        'rating_label': '',
        'runtime': '',
        'genres': [],
        'synopsis': 'Movie details not available.',
        'director': '',
        'cast': '',
      },
    );
  }

  /// Subset for watchlist display.
  static List<Map<String, dynamic>> get watchlistMovies =>
      movies.where((m) => ['1', '3', '5'].contains(m['id'])).toList();
}
