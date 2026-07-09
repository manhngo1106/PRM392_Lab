import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Local Storage Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab 9: JSON Local Storage'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.file_open), text: '9.1 Assets'),
              Tab(icon: Icon(Icons.save), text: '9.2 Simple Save'),
              Tab(icon: Icon(Icons.storage), text: '9.3 CRUD DB'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Lab9_1AssetReadScreen(),
            Lab9_2DeviceStorageScreen(),
            Lab9_3CrudDatabaseScreen(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LAB 9.1: Đọc JSON từ Assets
// ============================================================================
class Lab9_1AssetReadScreen extends StatefulWidget {
  const Lab9_1AssetReadScreen({super.key});

  @override
  State<Lab9_1AssetReadScreen> createState() => _Lab9_1AssetReadScreenState();
}

class _Lab9_1AssetReadScreenState extends State<Lab9_1AssetReadScreen> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssetJson();
  }

  Future<void> _loadAssetJson() async {
    try {
      // Đọc chuỗi JSON từ Assets
      final String response = await rootBundle.loadString('assets/data/initial_books.json');
      // Giải mã JSON thành List trong Dart
      final data = await jsonDecode(response);
      setState(() {
        _books = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _books.isEmpty
          ? const Center(child: Text('Không tìm thấy dữ liệu.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(book['id'] ?? '')),
                    title: Text(book['title'] ?? 'Không rõ tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tác giả: ${book['author'] ?? 'Không rõ'}'),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================================
// LAB 9.2: Lưu & Tải JSON từ bộ nhớ thiết bị
// ============================================================================
class Lab9_2DeviceStorageScreen extends StatefulWidget {
  const Lab9_2DeviceStorageScreen({super.key});

  @override
  State<Lab9_2DeviceStorageScreen> createState() => _Lab9_2DeviceStorageScreenState();
}

class _Lab9_2DeviceStorageScreenState extends State<Lab9_2DeviceStorageScreen> {
  final TextEditingController _itemController = TextEditingController();
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  // Định vị file lưu trữ cục bộ
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/simple_items.json');
  }

  // Đọc dữ liệu khi khởi động app
  Future<void> _loadLocalData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(contents);
        setState(() {
          _items = decoded.cast<String>();
        });
      }
    } catch (e) {
      debugPrint("Lỗi đọc dữ liệu: $e");
    }
  }

  // Lưu dữ liệu xuống bộ nhớ
  Future<void> _saveLocalData() async {
    final file = await _getLocalFile();
    final String jsonString = jsonEncode(_items);
    await file.writeAsString(jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu dữ liệu thành công!'), backgroundColor: Colors.green),
    );
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;
    setState(() {
      _items.add(_itemController.text.trim());
      _itemController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    labelText: 'Nhập tên mục mới',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Chưa có mục nào. Hãy thêm và nhấn Lưu.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        leading: Icon(Icons.label, color: Colors.teal.shade400),
                        title: Text(_items[index]),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveLocalData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              icon: const Icon(Icons.save_alt),
              label: const Text('Lưu Thay Đổi Vào Bộ Nhớ', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LAB 9.3: Mini Database CRUD + Search
// ============================================================================
class Lab9_3CrudDatabaseScreen extends StatefulWidget {
  const Lab9_3CrudDatabaseScreen({super.key});

  @override
  State<Lab9_3CrudDatabaseScreen> createState() => _Lab9_3CrudDatabaseScreenState();
}

class _Lab9_3CrudDatabaseScreenState extends State<Lab9_3CrudDatabaseScreen> {
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _searchController.addListener(_filterDatabase);
  }

  Future<File> _getDbFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/crud_books.json');
  }

  // Khởi tạo DB, nếu chưa có file ở bộ nhớ thì chép từ Asset ra để dùng làm data gốc
  Future<void> _initDatabase() async {
    final file = await _getDbFile();
    if (!await file.exists()) {
      try {
        final assetString = await rootBundle.loadString('assets/data/initial_books.json');
        await file.writeAsString(assetString);
      } catch (_) {}
    }
    await _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final file = await _getDbFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(content);
      setState(() {
        _allBooks = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        _filteredBooks = List.from(_allBooks);
      });
    }
  }

  // Tự động lưu sau mỗi hành động CRUD
  Future<void> _autoSaveToDisk() async {
    final file = await _getDbFile();
    await file.writeAsString(jsonEncode(_allBooks));
    _filterDatabase();
  }

  // Tìm kiếm lọc dữ liệu theo Tên sách hoặc Tác giả
  void _filterDatabase() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final title = (book['title'] ?? '').toLowerCase();
        final author = (book['author'] ?? '').toLowerCase();
        return title.contains(query) || author.contains(query);
      }).toList();
    });
  }

  // CRUD - Giao diện Hộp thoại Thêm / Sửa dữ liệu
  void _showBookFormDialog(Map<String, dynamic>? targetBook) {
    final isEditing = targetBook != null;
    if (isEditing) {
      _titleController.text = targetBook['title'];
      _authorController.text = targetBook['author'];
    } else {
      _titleController.clear();
      _authorController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông tin sách' : 'Thêm sách mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tên sách')),
            TextField(controller: _authorController, decoration: const InputDecoration(labelText: 'Tác giả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isEmpty || _authorController.text.isEmpty) return;
              
              setState(() {
                if (isEditing) {
                  final index = _allBooks.indexWhere((b) => b['id'] == targetBook['id']);
                  if (index != -1) {
                    _allBooks[index]['title'] = _titleController.text.trim();
                    _allBooks[index]['author'] = _authorController.text.trim();
                  }
                } else {
                  final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
                  _allBooks.add({
                    'id': uniqueId,
                    'title': _titleController.text.trim(),
                    'author': _authorController.text.trim(),
                  });
                }
              });
              _autoSaveToDisk();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Đã cập nhật sách.' : 'Đã thêm sách mới.'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          )
        ],
      ),
    );
  }

  // CRUD - Xóa dữ liệu kèm xác nhận (Bonus)
  void _confirmDelete(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa cuốn sách "${book['title']}" khỏi hệ thống không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _allBooks.removeWhere((b) => b['id'] == book['id']);
              });
              _autoSaveToDisk();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa sách khỏi bộ nhớ.'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('Xóa'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm theo tên sách hoặc tác giả...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(child: Text('Không tìm thấy kết quả phù hợp.'))
                : ListView.builder(
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(book['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Tác giả: ${book['author'] ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showBookFormDialog(book)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(book)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookFormDialog(null),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_to_photos),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}