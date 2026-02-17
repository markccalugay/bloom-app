---
description: How to deploy a clean build to the iOS simulator for demos
---

For iOS Simulators, Flutter only supports **Debug** mode. **Profile** and **Release** modes require a physical device. 

However, you can still get a "clean" experience for screenshots and videos on the simulator by using the existing configuration.

### 1. High-Fidelity Recording on Simulator
The project is already configured to hide the "Debug" banner in `lib/main.dart`:
```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  // ...
)
```

To run the app normally:
```bash
flutter run
```

### 2. Tips for Professional Demo Recording
- **Hide Debug Logs**: If you want a clean terminal while recording, you can use the `--quiet` flag:
  ```bash
  flutter run --quiet
  ```
- **Use Hot Key 'S'**: In the terminal where Flutter is running, you can press `S` (uppercase) to save a screenshot of the app directly to your project root.
- **Simulator Settings**: 
  - Go to **Simulator Menu > Window > Show Device Bezels** to toggle the phone frame.
  - Go to **Simulator Menu > File > Record Screen** to record high-quality video without cursor interference.

### 3. When to use a Physical Device
If you need to test actual performance (framerate, lag) or take "Store-ready" screenshots that require GPU-native behavior, you must run on a physical iPhone using:
```bash
flutter run --profile
```
(Follow the prompts to select your paired physical device)

> [!IMPORTANT]
> iOS Simulators are fundamentally limited by macOS CPU/GPU virtualization, so "Profile" mode is technically not possible. Debug mode on a modern Mac is usually smooth enough for most demo purposes.
