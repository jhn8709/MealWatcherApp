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
2) Open Xcode project by downloading this repository.
3) Set up Dropbox app and change Dropbox related information in code.
   ![dropbox_id](https://github.com/jhn8709/MealWatcherApp/assets/119468131/dfcc4f58-0786-47f6-b83b-226af947c933)
   ![dropbox_id2](https://github.com/jhn8709/MealWatcherApp/assets/119468131/115d004f-9fdd-4de0-85cd-850cf2d552b3)



5) If app is running, first go to settings tab and set participant ID.
6) Then, sync ring by pushing the sync button until a unique ID is generated for the ring.
7) In the main page there will be three large colored buttons, one for watch sensors, one for ring sensors, and one to set the camera for an image.
8) To toggle the sensors, either press the sensor buttons so that they are both green and display 'ON' or press the camera button with the 'Pre' setting bubble filled next to the camera button while the sensor buttons are red and display 'OFF'
9) Take an image of the meal before eating to initiate the sensors or after the sensors are initiated. Make sure the 'Pre' setting bubble is filled.
10) While the sensors are on, the user can freely use their phones and motion will be recorded in the background.
11) To turn sensors off, either press the sensor buttons so that they are both red and display 'OFF' or press the camera button with the 'Pose' setting bubble filled while the sensor buttons are green and display 'ON'
12) Take an image after the meal to toggle the sensors off or while the sensors are on. Make sure the 'Post' setting bubble is filled.
13) Click the survey button on the bottom to fill out a survey.
14) Dropbox upload should be automatic after sensors are turned off, but there is also a manual button to upload data.
15) It is recommended to completely close app after usage to wipe survey entries (will be fixed later).

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





