Quick start examples for integrating [Banuba SDK on iOS](https://docs.banuba.com/face-ar-sdk-v1/ios/ios_getting_started) into Swift apps.  
The example contains the following usecases:   
- apply effect to video from camera and show it on the screen,  
- apply effect to photo from the gallery,  
- apply effect to video from the gallery,  
- apply effect to video from camera and record video,
- apply Makeup effect to photo and use Makeup API in realtime.    
  
**Important**  
Please use [v0.x](../../tree/v0.x) branch for SDK version 0.x (e.g. v0.38).  
  
# Getting Started

1. Get the Banuba SDK client token. Please fill in our form on [form on banuba.com](https://www.banuba.com/face-filters-sdk) website, or contact us via [info@banuba.com](mailto:info@banuba.com).
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you don't have it.
3. Install required project dependencies by running `pod install`.
4. Copy and Paste your client token into appropriate section of `quickstart-ios-swift/quickstart-ios-swift/BanubaClientToken.swift`
5. Open generated workspace (not a project!) in Xcode and run the example.

# Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

# Testing

The project contains XCUITest in `quickstart-ios-swiftUITests`. For correct tests work `UItest` album should be created on device and should contain at least one photo and one video inside.
