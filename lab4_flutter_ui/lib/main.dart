import 'package:flutter/material.dart';

void main() {
  runApp(const Lab4App());
}

// ---------------------------------------------------------
// ROOT APP (Quản lý Theme cho Exercise 4)
// ---------------------------------------------------------
class Lab4App extends StatefulWidget {
  const Lab4App({super.key});

  @override
  State<Lab4App> createState() => _Lab4AppState();
}

class _Lab4AppState extends State<Lab4App> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 4 - Flutter UI',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: MainMenuScreen(onThemeToggle: toggleTheme, currentTheme: _themeMode),
    );
  }
}

// ---------------------------------------------------------
// MAIN MENU (Màn hình chính điều hướng đến 5 bài tập)
// ---------------------------------------------------------
class MainMenuScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const MainMenuScreen({super.key, required this.onThemeToggle, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 4 – Flutter UI Fundamentals')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuButton(context, 'Exercise 1 – Core Widgets Demo', const Exercise1Screen()),
          _buildMenuButton(context, 'Exercise 2 – Input Controls Demo', const Exercise2Screen()),
          _buildMenuButton(context, 'Exercise 3 – Layout Demo', const Exercise3Screen()),
          _buildMenuButton(
            context, 
            'Exercise 4 – App Structure & Theme', 
            Exercise4Screen(onThemeToggle: onThemeToggle, currentTheme: currentTheme)
          ),
          _buildMenuButton(context, 'Exercise 5 – Common UI Fixes', const Exercise5Screen()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      ),
    );
  }
}

// ---------------------------------------------------------
// EXERCISE 1: Core Widgets Demo
// ---------------------------------------------------------
class Exercise1Screen extends StatelessWidget {
  const Exercise1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise 1 – Core Widgets')),
      // SingleChildScrollView helps prevent overflow on small devices (Ex 5 fix applied)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Headline Text
            const Text(
              'Welcome to Flutter UI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 2. Icon
            const Icon(Icons.movie, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            
            // 3. Image.network
            Image.network(
              'https://picsum.photos/400/200', // Placeholder image
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            
            // 4. Card containing a ListTile
            const Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('Movie Item'),
                subtitle: Text('This is a sample ListTile inside a Card.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// EXERCISE 2: Input Controls Demo
// ---------------------------------------------------------
class Exercise2Screen extends StatefulWidget {
  const Exercise2Screen({super.key});

  @override
  State<Exercise2Screen> createState() => _Exercise2ScreenState();
}

class _Exercise2ScreenState extends State<Exercise2Screen> {
  double _rating = 50.0;
  bool _isActive = false;
  String? _selectedGenre;
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise 2 – Input Controls')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Slider
          const Text('Rating (Slider)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Slider(
            value: _rating,
            min: 0,
            max: 100,
            onChanged: (value) => setState(() => _rating = value),
          ),
          Text('Current value: ${_rating.toInt()}'),
          const Divider(),

          // Switch
          const Text('Active (Switch)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            title: const Text('Is movie active?'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const Divider(),

          // RadioListTile
          const Text('Genre (RadioListTile)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          RadioGroup<String>(
            groupValue: _selectedGenre,
            onChanged: (value) => setState(() => _selectedGenre = value),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Action'),
                  value: 'Action',
                ),
                RadioListTile<String>(
                  title: const Text('Comedy'),
                  value: 'Comedy',
                ),
              ],
            ),
          ),
          Text('Selected genre: ${_selectedGenre ?? "None"}'),
          const Divider(),

          // Date Picker
          ElevatedButton(
            onPressed: () => _pickDate(context),
            child: const Text('Open Date Picker'),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// EXERCISE 3: Layout Demo
// ---------------------------------------------------------
class Exercise3Screen extends StatelessWidget {
  const Exercise3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> movies = ['Avatar', 'Inception', 'Interstellar', 'Joker'];

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise 3 – Layout Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding applied
        child: Column(
          children: [
            const Text(
              'Now Playing',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Spacing
            
            // Expanded is necessary here so the ListView takes remaining space
            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(movies[index][0]), // First letter
                      ),
                      title: Text(movies[index]),
                      subtitle: const Text('Sample description'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// EXERCISE 4: App Structure & Theme
// ---------------------------------------------------------
class Exercise4Screen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const Exercise4Screen({super.key, required this.onThemeToggle, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    bool isDark = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 4 – App Structure'),
        actions: [
          Row(
            children: [
              Text(isDark ? 'Light' : 'Dark'),
              Switch(
                value: isDark,
                onChanged: (val) => onThemeToggle(),
                activeThumbColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(
        child: Text('This is a simple screen with theme toggle.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------
// EXERCISE 5: Common UI Fixes
// ---------------------------------------------------------
class Exercise5Screen extends StatelessWidget {
  const Exercise5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise 5 – Common UI Fixes')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Correct ListView inside Column using Expanded',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // FIX: ListView inside Column must be wrapped in Expanded or Flexible
          // Without Expanded, the ListView takes infinite height and crashes.
          Expanded(
            child: ListView(
              children: const [
                ListTile(leading: Icon(Icons.movie), title: Text('Movie A')),
                ListTile(leading: Icon(Icons.movie), title: Text('Movie B')),
                ListTile(leading: Icon(Icons.movie), title: Text('Movie C')),
                ListTile(leading: Icon(Icons.movie), title: Text('Movie D')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}