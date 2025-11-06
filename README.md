# 🌀 Platform Channels in Flutter — Shake Quote App

This project was created to **experiment and learn about Platform Channels in Flutter**, specifically how to communicate between **Flutter (Dart)** and **native Android (Kotlin)** code.

The app demonstrates using an **EventChannel** to detect phone shakes via Android's accelerometer sensor, and then sending those events to Flutter to display a **motivational quote** with an animation.

---

## 📱 Features
- Uses **EventChannel** to receive real-time shake events from Android native code.  
- Smooth animated quote display when a shake is detected.  
- Implemented in **Flutter (Dart)** and **Kotlin**.  
- Simple UI with smooth transitions.  

---

## 🧠 Learning Purpose
This project was built for educational purposes while studying **Platform Channels in Flutter** — learning how to:
- Set up a communication bridge between Flutter and native code.
- Handle sensor data (accelerometer) in Kotlin.
- Send events from Android to Flutter using `EventChannel`.

---

## ⚙️ How It Works

### On Android (Kotlin)
- The app listens to accelerometer sensor data.
- When motion exceeds a threshold, it detects a *shake event*.

```kotlin
  EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.shake/event")
  
 ````

### On Flutter (Dart)
- The app listens to the EventChannel stream
 
```dart
static const EventChannel _eventChannel = EventChannel('com.example.shake/event');
```

- When a shake is detected, a random motivational quote is shown with an animation.


## 🧩 Code Structure

```
lib/
 └── main.dart          # Flutter side (UI + EventChannel listener)
android/
 └── MainActivity.kt    # Native Android side (sensor + EventChannel sender)
```

## 🧰 Technologies Used

- Flutter (Dart)

- Kotlin

- EventChannel communication

- Android Sensors API
