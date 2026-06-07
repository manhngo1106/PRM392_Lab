import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiveMovieApp());
}

// ==========================================
// 1. DATA MODEL & SAMPLE DATA
// ==========================================
class Movie {
  final String title;
  final int year;
  final List<String> genres;
  final String posterUrl;
  final double rating;

  Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });
}

// Sample Data
final List<Movie> allMovies = [
  Movie(
    title: "Dune: Part Two",
    year: 2024,
    genres: ["Sci-Fi", "Adventure", "Drama"],
    posterUrl: "https://picsum.photos/seed/dune/200/300",
    rating: 8.8,
  ),
  Movie(
    title: "Deadpool & Wolverine",
    year: 2024,
    genres: ["Action", "Comedy"],
    posterUrl: "https://picsum.photos/seed/deadpool/200/300",
    rating: 8.3,
  ),
  Movie(
    title: "Oppenheimer",
    year: 2023,
    genres: ["Drama", "History"],
    posterUrl: "https://picsum.photos/seed/oppenheimer/200/300",
    rating: 8.4,
  ),
  Movie(
    title: "Spider-Man: Across the Spider-Verse",
    year: 2023,
    genres: ["Animation", "Action", "Adventure"],
    posterUrl: "https://picsum.photos/seed/spidey/200/300",
    rating: 8.6,
  ),
  Movie(
    title: "The Fall Guy",
    year: 2024,
    genres: ["Action", "Comedy"],
    posterUrl: "https://picsum.photos/seed/fallguy/200/300",
    rating: 7.1,
  ),
  Movie(
    title: "Interstellar",
    year: 2014,
    genres: ["Sci-Fi", "Drama", "Adventure"],
    posterUrl: "https://picsum.photos/seed/interstellar/200/300",
    rating: 8.6,
  ),
];

// All available genres derived from the sample data
final List<String> availableGenres = [
  "Action", "Adventure", "Animation", "Comedy", "Drama", "History", "Sci-Fi"
];

// Sort Options
const List<String> sortOptions = ["A-Z", "Z-A", "Year", "Rating"];

// ==========================================
// 2. ROOT APP
// ==========================================
class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 6 - Responsive Movies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const GenreScreen(),
    );
  }
}

// ==========================================
// 3. MAIN SCREEN (Stateful)
// ==========================================
class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  // State variables for filtering and sorting
  String searchQuery = '';
  Set<String> selectedGenres = {};
  String selectedSort = sortOptions.first; // Default to "A-Z"

  // Function to clear all filters (Bonus Enhancement)
  void _clearFilters() {
    setState(() {
      searchQuery = '';
      selectedGenres.clear();
      selectedSort = sortOptions.first;
    });
  }

  // Filter and sort the movie list based on state
  List<Movie> get _visibleMovies {
    // 1. Filter
    var filtered = allMovies.where((movie) {
      final matchesSearch = movie.title.toLowerCase().contains(searchQuery.toLowerCase());
      // If no genres selected, show all. Otherwise, check for intersection.
      final matchesGenre = selectedGenres.isEmpty || 
                           movie.genres.any((g) => selectedGenres.contains(g));
      return matchesSearch && matchesGenre;
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      switch (selectedSort) {
        case "A-Z":
          return a.title.compareTo(b.title);
        case "Z-A":
          return b.title.compareTo(a.title);
        case "Year":
          return b.year.compareTo(a.year); // Newest first
        case "Rating":
          return b.rating.compareTo(a.rating); // Highest first
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final visibleMovies = _visibleMovies;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Find a Movie",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  // Clear Filters Button (Bonus)
                  if (searchQuery.isNotEmpty || selectedGenres.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text("Clear Filters"),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Search Bar ---
              TextField(
                decoration: InputDecoration(
                  hintText: "Search by title...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Genre Chips (Responsive Wrap) ---
              Row(
                children: [
                  const Text(
                    "Genres",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  // Selected count badge (Bonus)
                  if (selectedGenres.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedGenres.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: availableGenres.map((genre) {
                  final isSelected = selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // --- Sort Dropdown ---
              Row(
                children: [
                  const Text("Sort By: ", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedSort,
                    items: sortOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSort = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Responsive Movie List ---
              Expanded(
                child: visibleMovies.isEmpty
                    ? const Center(child: Text("No movies match your filters."))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // BREAKPOINT LOGIC: ≥ 800px is tablet/web layout
                          if (constraints.maxWidth >= 800) {
                            // Two-column Grid for wide screens
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.5, // Adjusts height of the card
                              ),
                              itemCount: visibleMovies.length,
                              itemBuilder: (context, index) {
                                return MovieCard(movie: visibleMovies[index]);
                              },
                            );
                          } else {
                            // Single-column List for phones
                            return ListView.builder(
                              itemCount: visibleMovies.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: MovieCard(movie: visibleMovies[index]),
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. MOVIE CARD WIDGET
// ==========================================
class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          Image.network(
            movie.posterUrl,
            width: 100,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          ),
          // Movie Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Year: ${movie.year}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  // Rating (Bonus)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Genres wrap inside the card
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: movie.genres.map((g) {
                      return Text(
                        g,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}