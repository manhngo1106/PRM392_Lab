# LAB 12 REPORT — PERFORMANCE OPTIMIZATION & DEPLOYMENT

* **Course**: PRM392 (Mobile Application Development)
* **Lab Number**: Lab 12
* **Project**: Taskly (Optimized Web Version)

---

## 🔶 Exercise 12.1 — Optimize List Rebuilds in Taskly

### Objective
Reduce unnecessary widget rebuilds when adding, toggling, and deleting tasks.

### Optimizations Implemented
1. **Widget Extraction**: Extracted the inline `ListTile` into a separate, focused, custom `TaskTile` widget in `lib/widgets/task_tile.dart` with a `const` constructor.
2. **Provider Selector**: Replaced the custom InheritedWidget with the standard `provider` package.
   - Wrapped `ListView.builder` inside a `Selector<TaskProvider, List<Task>>` so it only rebuilds when items are added or deleted.
   - Used `Provider.of<TaskProvider>(context, listen: false)` for button actions (adding, deleting, toggling) so that typing or clicking does not trigger rebuilds on the text fields or static layout.
3. **Key Assignment**: Assigned explicit `ValueKey<String>(task.id)` to each `TaskTile` in the list to help Flutter's framework track items efficiently during list modifications.
4. **Const Widgets**: Applied `const` to all static UI components, including empty state widgets, input decorations, and titles.

### Code Comparison

#### Before (Inline ListTile in Screen):
```dart
// Rebuilds entire screen on any provider update:
final repository = TaskRepositoryProvider.of(context);
final tasks = repository.tasks;
// ...
ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (context, index) {
    final task = tasks[index];
    return ListTile(...); // Inline rebuilds
  }
)
```

#### After (Optimized Selector & Extracted Widget):
```dart
// Selector rebuilds ONLY the list when task list instance updates:
Selector<TaskProvider, List<Task>>(
  selector: (context, provider) => provider.tasks,
  builder: (context, tasks, child) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          key: ValueKey<String>(task.id),
          task: task,
        );
      },
    );
  },
)
```

---

## 🔶 Exercise 12.2 — Image & Asset Optimization

### Objective
Optimize static images and assets to improve network performance and reduce total application build size.

### Optimizations Implemented
1. **Asset Selection**: Added a test image at `assets/app_logo.png` representing the application icon.
2. **Resolution Downscaling & Compression**: Resized the original logo image to `128x128` pixels using a PowerShell GDI+ script, reducing its size to **12.13 KB**.
3. **Asset Pre-caching**: Implemented `precacheImage` inside the lifecycle method `didChangeDependencies` of `TaskListScreen` to preload the asset into memory immediately when the screen initializes, ensuring zero-latency rendering.

### Code Snippet: Asset Pre-caching
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Pre-cache the application logo to improve image load speed
  precacheImage(const AssetImage('assets/app_logo.png'), context);
}
```

---

## 🔶 Exercise 12.3 — App Size Analysis

### Objective
Analyze compiled size to identify large asset/library contributions and recommend optimizations.

### Size Analysis Results (Web Build)
We ran a recursive directory size analysis script on the compiled files in `build/web`:

| Filename | Path | Size (Bytes) | Size (KB) | Purpose |
|---|---|---|---|---|
| `canvaskit.wasm` | `canvaskit/canvaskit.wasm` | 7,229,467 | 7,060.03 | Graphic rendering engine |
| `canvaskit.wasm` | `canvaskit/chromium/canvaskit.wasm` | 5,760,502 | 5,625.49 | Chromium optimized engine |
| `skwasm_heavy.wasm` | `canvaskit/skwasm_heavy.wasm` | 5,172,643 | 5,051.41 | High-perf rendering engine |
| `main.dart.js` | `main.dart.js` | 2,453,055 | 2,395.56 | Compiled Flutter app logic |
| `NOTICES` | `assets/NOTICES` | 1,320,485 | 1,289.54 | License notices |
| `app_logo.png` | `assets/app_logo.png` | 12,133 | 12.13 | Resized and optimized app logo |

### Key Observations
1. **CanvasKit Engine**: CanvasKit WebAssembly engines take up the bulk of the size (~17MB combined). This is normal for Flutter web apps to ensure native-like rendering performance.
2. **License Notices**: The `NOTICES` file takes up `1.29 MB` (over 10% of the non-wasm package size).
3. **Optimized Assets**: The optimized `app_logo.png` consumes only **12.13 KB**, which is highly efficient.

### Optimization Suggestions
- **Remove/Compress NOTICES**: We can compile with `--no-tree-shake-icons` disabled or strip out/gzip the `NOTICES` file if licenses are presented through another medium.
- **WASM Web Build**: Build using the `--wasm` flag to compile Flutter web apps directly to WASM, which offers smaller bundle sizes and faster execution speeds.
- **HTML Renderer**: Build with `flutter build web --web-renderer html` to completely bypass CanvasKit WASM downloads if maximum loading speed is required for low-end networks.

---

## 🔶 Exercise 12.4 — Final Optimization & Deployment

### Performance Checklist
- [x] No `print()` or debug logs remain in production paths.
- [x] All static layouts are marked `const` to save memory allocation cycles.
- [x] Asset images are resized, optimized, and pre-cached.
- [x] Target icons are tree-shaken (reducing CupertinoIcons from 257KB to 1.4KB).
- [x] Project is compiled in full **Release** mode (`flutter build web --release`).

### Verification & Deployment Readiness
- The application was deployed onto a local release server and successfully tested using Chrome.
- Actions (adding tasks, checking items off, and deleting items) perform instantly without lag.
- **Why the app is ready for deployment**: Unnecessary widget rebuilds have been engineered out using the `Selector` pattern, assets are optimized down to a few kilobytes, icon tree-shaking is active, and the production build contains zero debugging overhead.
