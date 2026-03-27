# Keep all TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }

# Keep GPU delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }

# Prevent warnings
-dontwarn org.tensorflow.lite.**