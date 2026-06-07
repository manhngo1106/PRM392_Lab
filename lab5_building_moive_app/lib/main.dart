import 'package:flutter/material.dart';

void main() {
  runApp(const MovieApp());
}

// ==========================================
// 1. DATA MODEL & SAMPLE DATA
// ==========================================

class Trailer {
  final String title;
  final String thumbnail;

  Trailer({required this.title, required this.thumbnail});
}

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String overview;
  final List<String> genres;
  final double rating;
  final List<Trailer> trailers;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
  });
}

// Static Sample Data
final List<Movie> sampleMovies = [
  Movie(
    id: '1',
    title: 'Inception',
    posterUrl: 'https://picsum.photos/seed/inception/600/400',
    overview: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
    genres: ['Action', 'Sci-Fi', 'Thriller'],
    rating: 8.8,
    trailers: [
      Trailer(title: 'Official Trailer 1', thumbnail: 'https://picsum.photos/seed/t1/200/100'),
      Trailer(title: 'Teaser Trailer', thumbnail: 'https://picsum.photos/seed/t2/200/100'),
    ],
  ),
  Movie(
    id: '2',
    title: 'Interstellar',
    posterUrl: 'https://picsum.photos/seed/interstellar/600/400',
    overview: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
    genres: ['Adventure', 'Drama', 'Sci-Fi'],
    rating: 8.6,
    trailers: [
      Trailer(title: 'Launch Trailer', thumbnail: 'https://picsum.photos/seed/t3/200/100'),
    ],
  ),
  Movie(
    id: '3',
    title: 'The Dark Knight',
    posterUrl: 'https://picsum.photos/seed/darkknight/600/400',
    overview: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
    genres: ['Action', 'Crime', 'Drama'],
    rating: 9.0,
    trailers: [
      Trailer(title: 'Main Trailer', thumbnail: 'https://picsum.photos/seed/t4/200/100'),
      Trailer(title: 'Joker Reveal', thumbnail: 'https://picsum.photos/seed/t5/200/100'),
    ],
  ),
];

// ==========================================
// 2. ROOT APP
// ==========================================

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Detail App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// 3. HOME SCREEN
// ==========================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sampleMovies.length,
        itemBuilder: (context, index) {
          final movie = sampleMovies[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: InkWell(
              // NAVIGATION STEP: Use Navigator.push and MaterialPageRoute to pass the Movie object
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              child: Row(
                children: [
                  Image.network(
                    movie.posterUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text('${movie.rating}/10'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.genres.join(', '),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. MOVIE DETAIL SCREEN
// ==========================================

// Made Stateful to support the "Favorite toggle" optional enhancement
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false; // State variable for the Favorite toggle

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Allows the hero banner to sit behind the AppBar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner (Stack + Image.network + Gradient)
            Stack(
              children: [
                Image.network(
                  movie.posterUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        const Color(0xFF121212), // Fades into background color
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Genres (Wrap + Chip)
                  Wrap(
                    spacing: 8.0,
                    children: movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        backgroundColor: Colors.blueGrey.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons Row (Favorite, Rate, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Favorite Toggle Button
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.redAccent : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                          const Text('Favorite'),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(icon: const Icon(Icons.star_border), onPressed: () {}),
                          const Text('Rate'),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                          const Text('Share'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Overview Text
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  // Trailer List
                  const Text(
                    'Trailers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Using ListView.builder inside a SingleChildScrollView requires shrinkWrap & NeverScrollableScrollPhysics
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: movie.trailers.length,
                    itemBuilder: (context, index) {
                      final trailer = movie.trailers[index];
                      return Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(trailer.thumbnail, width: 80, fit: BoxFit.cover),
                              const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                            ],
                          ),
                          title: Text(trailer.title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}