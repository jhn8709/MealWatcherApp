# MealWatcherApp

<h4 align="center">An iOS app to track motion data from the Apple Watch and Genki Wave ring for research that analyzes movement patterns during meals.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#download">Download</a> •
  <a href="#credits">Credits</a> •
</p>

## Key Features

* Connection to Apple Watch through WatchConnectivity library.
  - Allows messaging between phone and watch while both are on to toggle sensors quickly.
  - Allows messaging when watch is asleep so that watch updates upon waking.
  - Enables file transfers so that data on watch can be transferred to the phone.
* Connection to Genki Wave Ring through CoreBluetooth library.
  - Creates a unique ID that allows the app to only interact with a specific ring
  - Connects to ring to receive data payloads
* Interactive UI that allows users to toggle sensors on iPhone or Apple Watch and know when the sensors are on for privacy purposes.
* Dark/Light mode support
* Settings tab can be used to change files names according to the participant's ID for organization of data.
  - Also used for syncing Genki Wave Ring
* Includes camera functionality so that images of meals can be taken.
* Includes surveys to help researchers assess user's eating patterns.
* App will stay awake in background while sensors are on to not inconvenience users.
* Send data to Dropbox so that any operating system can access the data.

## How To Use

1) Sync Apple Watch to iPhone if needed.
2) Set up Dropbox App here
   - 
4) 

## Download

You can download the source code for the app in this repository


## Credits

This software uses the following open source packages:

- [SwiftSurvey](https://github.com/laanlabs/SwiftSurvey)
- [KeyboardAwareSwiftUI](https://github.com/ralfebert/KeyboardAwareSwiftUI)
- [SwiftyDropbox](https://github.com/dropbox/SwiftyDropbox)
- [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth)
- [HealthKit](https://developer.apple.com/documentation/healthkit)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)
- [WatchKit](https://developer.apple.com/documentation/watchkit)





> GitHub [@jhn8709](https://github.com/jhn8709) &nbsp;&middot;&nbsp;



