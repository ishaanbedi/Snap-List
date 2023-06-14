# Snap List

Snap List is an iOS app, which utilizes CoreML and MobileNetV2 model to detect items using the user's camera and allows the user to add them to their list with persistence using UserDefaults. 


## Features
- Camera-based item detection: The Snap List app uses the device's camera to capture images and applies the MobileNetV2.mlmodel for item detection. It can recognize various objects based on the model's training data.
- Item list management: Users can add the detected items to their list for future reference.
- Persistence using UserDefaults: The app leverages UserDefaults to store and retrieve the user's item list, ensuring persistence across app launches.

## Prerequisites

You will need an iOS device to run the app since the camera functionality is utilized, which cannot be leveraged using the iOS Simulator on macOS.

## Installation

- Clone or download the repository to your local machine.
- Open the project in Xcode by double-clicking the Snap Snap List.xcodeproj file.
- Connect your iOS device to your Mac.
- Select your device as the build target in Xcode.
- Build and run the app on your iOS device.

## Usage

- Launch the Snap List app on your iOS device.

- Grant necessary permissions for camera access as the app will utilize the device's camera for item detection.
- Point the camera towards an object you want to detect.
- Wait for the app to analyze the image and detect the object.
- Once the object is detected, it will be displayed on the screen.
- Tap the "Add to List" button to add the detected object to your item list if you believe the detection is accurate, otherwise you can try again or add a custom name for the object.
- The item will be persisted using UserDefaults, allowing it to be accessible even after app restarts (I haven't implemented SwiftData because it requires iOS 17 Beta and I really don't want to smash my device with a hammer out of frustration, yet).

## Model - MobileNetV2

The Snap List app utilizes the MobileNetV2.mlmodel for item detection. MobileNetV2 is a convolutional neural network architecture designed for efficient on-device image classification and object detection. 

It has been trained on a large dataset to recognize a wide range of objects accurately.

It is 53 layers deep and can classify images into 1000 object categories, such as keyboard, mouse, pencil, and many animals. It is optimized for mobile devices and can run in real-time on high-end mobile devices.

The MobileNetV2.mlmodel file is included in the app's bundle and is used by CoreML for real-time object detection.


## License
The Snap List app is released under the MIT License.

## More
If you encounter any issues or have questions or suggestions, please feel free to reach out to me at [sl@ishaanbedi.in](mailto:sl@ishaanbedi.in).

The accuracy and performance of the item detection functionality heavily rely on the training data and the MobileNetV2 model. There are instances where objects are misclassified or not detected correctly. I am learning more about machine learning and integrating it into iOS apps!