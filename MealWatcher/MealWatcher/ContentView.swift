//
//  ContentView.swift
//  BiteCounterProject
//
//  This file contains the main view or UI of the app.
// 
//  Created by Jimmy Nguyen on 6/8/23.
//

import SwiftUI
import HealthKit
import WatchConnectivity
import SwiftyDropbox
import CoreBluetooth

/* This class is used to provide haptic feedback when certain buttons are pressed. Haptic
   feedback is useful for grabbing the user's attention for issues in the app */
class HapticManager {
    
    static let instance = HapticManager() // Singleton
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("watchSensor") var sensorFlag: Bool = false
    @State var PrePostFlag: Bool = false 
    
    // Camera variables
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    // Watch connection variables
    @State var reachable = "Disconnected"
    @State var messageText = ""
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    let applicationContext = ["sensor-flag":true]
    @AppStorage("storedID") var participantID: String = "P9999"
    
    /* File manager variables */
    @StateObject private var vm = FileManagerViewModel()
    @State var dataCount = 0
    let exampleURL = URL(string: "https://www.example.com")!
    
    /* Data and time varaiable */
    @State private var timeStamp: String = "Unknown"
    
    /* DropBox Variables */
    @State var client = DropboxClient(accessToken: "Fetch Token First")
    @State var accessToken: String = ""
    @State var showDBAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var allowPayloadSubmission: Bool = false
    
    /* History View Data */
//    @State var historyList: [String] = []
//    @State var navigateToHistoryView = false
    
    /* Settings View Variables */
    @State var navigateToSettingsView = false
    @State var ringID = 0
    
    /* Genki Ring Variables */
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel.instance
    @State var ringConnection: Bool = false
    @AppStorage("ringUUID") var ringUUIDString: String = ""
    
    /* Survey Variables */
    @State var navigateToSurveyView: Bool = false
    
    var body: some View {
        NavigationView { // NavigationView is used since this view is used to traverse to other views
            ScrollView { // ScrollView allows the user to scroll up and down the UI. Necessary if all UI elements do not fit on one screen.
                
                /* This VStack is used for the two buttons on the top. The left is used to quickly check the watch connection and the right button is used to navigate to settings page.
                VStack(alignment: .leading) {
                    HStack {
                        /* Checks watch connectivity */
                        CheckWatchConnection(model: connectivityManager, reachable: $reachable)
                        /* Navigates to setting view */
                        Spacer()
                        
                        Button("Settings") {
                            navigateToSettingsView = true
                            print("Navigate to settings")
                            
                        }
                        NavigationLink(destination: SettingsView(participantID: $participantID, selectedOption: $ringID, ringUUIDString: $ringUUIDString), isActive: $navigateToSettingsView) {
                            EmptyView()
                        }
                    }

                    /* This button shows how many files are in the main directory used to store files for this app. If pressed, the display for the button is refreshed */
                    Button {
                        dataCount = vm.listSize()
                        
                    } label: {
                        Text("File Count \(dataCount)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    .padding()

                    /* This HStack contains the buttons for both the watch and the ring sensors */
                    HStack {
                        VStack {
                            Text("Watch Sensors")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Button {
                                wakeOrToggle(cameraUse: false)
                            } label: {
                                SensorButton(flag: connectivityManager.sensorFlag)
                            }
                        }
                        .padding(.horizontal)
                        VStack {
                            Text("Ring Sensors")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Button (action: {
                                //print("\(waveRing.state)")
                                print("Ring Button Pressed")
                                toggleRing()
                            }, label: {
                                RingSensorButton(state: bluetoothViewModel.isRunning)
                            })
                        }
                    }

                    /* The button on the left is used when camera function is needed and the two buttons on the right designate the 
                       image where 'pre' and 'post' being before and after respectively */
                    Text("Camera")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 85.0)
                    HStack {
                        Button {
                            if connectivityManager.sensorFlag == false && PrePostFlag == false {
                                wakeOrToggle(cameraUse: true)
                            }
                            else if connectivityManager.sensorFlag == true && PrePostFlag == true {
                                wakeOrToggle(cameraUse: true)
                            }
                            else {
                                self.sourceType = .camera
                                self.isImagePickerDisplay.toggle()
                            }
                            HapticManager.instance.notification(type: .success)
                        } label: {
                            Text("take picture")
                                .bold()
                                .font(.title2)
                                .frame(width: 250, height: 200)
                                .background(Color(.systemGray))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        PictureModeCircle(flag: $PrePostFlag)
                    }
                    .padding(.horizontal)
                    Spacer()

                    /* This VStack has the survey button and the send to Dropbox button.
                    VStack(alignment: .center) {
                        Button(action: {
                            navigateToSurveyView = true
                        }, label: {
                            StandardButton(title: "Survey")
                        })
                        .padding(.vertical)
                        NavigationLink(destination: SurveyView(survey: EMAQuestions, participantID: self.participantID), isActive: $navigateToSurveyView) {
                            EmptyView()
                        }
                        
                        DropBoxView(client: $client, participantID: participantID, iOSFiles: vm, showAlert: $showDBAlert, alertTitle: $alertTitle, alertMessage: $alertMessage)
                            .alert(isPresented: $showDBAlert, content: {
                                Alert(
                                    title: Text(alertTitle),
                                    message: Text(alertMessage),
                                    dismissButton: .default(Text("OK")))
                            })
                        
                    }
                    .padding()


                }
            }
            .sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType, PrePostFlag: $PrePostFlag, participantID: self.$participantID)
            }
            .padding()
            .onChange(of: bluetoothViewModel.isRunning) { state in
                if state == true && bluetoothViewModel.allowNotifications == true {
                    self.ringConnection = true
                }
                else {
                    self.ringConnection = false
                }
            }
            /* This onChange function waits for a file that is sent from the watch to the phone. A file is sent after recording on the watch is stopped. 
            .onChange(of: connectivityManager.fileURL ?? exampleURL) { CSVFileURL in
                if let waveRing = bluetoothViewModel.connectedPeripheral { 
                    /* If waveRing is recording while watch recording has been stopped, stop the recording on the ring */
                    if waveRing.state == .connected {
                        bluetoothViewModel.stopRecording()
                        bluetoothViewModel.disconnect(peripheral: waveRing)
                        ringConnection = false
                    }
                }
                if connectivityManager.fileURL != exampleURL {
                    print("New CSV file being read")
                    print("\(CSVFileURL)")
            
                    guard let fileData = connectivityManager.fileData else {return} // check if the file has data and is not empty
                    /* Save the file to the directory and if success, send all data in directory to Dropbox
                       Note that the function is saveCSV which might be outdated but it is used to save data files in general */
                    vm.saveCSV(fileURL: CSVFileURL, fileData: fileData) { completed in
                        if completed {
                            submitPayload(participantID: participantID, iOSFiles: vm) { client in
                                if let client = client {
                                    self.client = client
                                }
                                else {
                                    print("Error submitting payload")
                                }
                            }
                        }
                    }

                    
                }
                else {
                    print("Initialization of Failed to read CSV file")
                }
            }
            /* The ring sometimes connects but does not send data payloads. If this happens an alert is sent to tell the user to restart the ring */
            .alert(isPresented: $bluetoothViewModel.errorFlag) {
                    Alert(
                        title: Text("Ring not recording properly"),
                        message: Text("Please try resetting the ring by pressing, holding, and then releasing the top and bottom button at the same time. The buttons are located above and below the main daimond button."),
                        dismissButton: .default(Text("OK")))
            }
        }
    }

    /* Function that sends a message to the Apple Watch so that both know that sensors are on */
    func toggleSensors() {
        WCSession.default.sendMessage(["sensor-flag" : true], replyHandler: { reply in
            print(reply)
            if let flag = reply["sensor-flag"] as? Bool {
                DispatchQueue.main.async {
                    connectivityManager.sensorFlag = flag
                }
            }
        },
        errorHandler: { (error) in
            print("Error with button press")
        })
        /* Note that to send messages, BOTH devices need to be on and awake. Updating application context will update even if watch is asleep but had bugs.
           For now, sending a message has worked better to keep the devices in sync. Uncomment the code below to test using application context. */
//        print("Toggling Sensors")
//        guard WCSession.default.activationState == .activated else {
//            print("Session not activated")
//            return //handleSessionUnactivated(with: commandStatus)
//        }
//        DispatchQueue.main.async {
//            do {
//                try WCSession.default.updateApplicationContext(["sensor-flag" : true])
//                print("Application context updated to: \(connectivityManager.sensorFlag)")
//            } catch {
//                print("Error updating application context!")
//                
//            }
//        }
    }

    /* Calls the startWatchApp function which should launch the watchOS companion app. */
    func wakeUpWatch() {
        if connectivityManager.session.isReachable {
            reachable = "Connected"
        }
        else {
            reachable = "Disconnected"
            startWatchApp(connectivityManager.session) { launched in
                if launched && connectivityManager.session.isReachable {
                    reachable = "Connected"
                }
            }
        }
    }

    /* This function will toggle the sensors if the watch and watch app is reachable. If the watch 
       is not reachable, then it will try to launch the watch app using the wakeUpWatch() func */
    func wakeOrToggle(cameraUse: Bool) {
        //print("\(WCSession.default.activationState)")
        if connectivityManager.session.isReachable {
            reachable = "Connected"
            // toggle sensors on
            toggleSensors()
            if cameraUse == true {
                self.sourceType = .camera
                self.isImagePickerDisplay.toggle()
                toggleRing()
            }
            HapticManager.instance.notification(type: .success)
        }
        else {
            // pull up watch app if not connected
            if !WCSession.default.isReachable {
                let message = ["wakeUp": true]
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending message: \(error.localizedDescription)")
                    wakeUpWatch()
                }
            }
            reachable = "Connected"
            //print("Camera button watch wake up")
        }
    }

    /* This function is used to connect to the ring with a certain UUID, create a new data file to record motion 
       data from the ring, and initiate the datastream on the ring to the phone. */
    func connectToRing() {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        bluetoothViewModel.filename = participantID+"-"+df.string(from: date)+"-ring"
        if ringUUIDString.isEmpty {
            print("Ring UUID not assigned yet")
            return
        }
        print("Attempting to connect with UUID: \(ringUUIDString)")
        bluetoothViewModel.allowNotifications = true
        guard let ringUUID = UUID(uuidString: self.ringUUIDString) else {
            print("Error: UUID does not exist")
            return
        }
        bluetoothViewModel.connectWithUUID(ringUUID: ringUUID)
        guard let filename = bluetoothViewModel.filename else {
            print("Error: File name does not exist")
            return
        }
        bluetoothViewModel.currentURL = vm.getDataFilePath(fileName: filename)
        guard let currentURL = bluetoothViewModel.currentURL else {
            print("Error: File path does not exist")
            return
        }
        bluetoothViewModel.startRecording(fileURL: currentURL)
    }

    /* This function is used to connect to the ring if ring is disconnected and disconnects if ring is 
       currently connected and recording. */
    func toggleRing() {
        if let waveRing = bluetoothViewModel.connectedPeripheral {
            if waveRing.state == .connected {
                bluetoothViewModel.stopRecording()
                bluetoothViewModel.disconnect(peripheral: waveRing)
                ringConnection = false
                
            }
            else {
                connectToRing()
            }
        }
        else {
            connectToRing()
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct StandardButton: View {
    
    var title: String
    
    var body: some View {
        Text(title)
            .bold()
            .font(.title2)
            .frame(width: 280, height: 50)
            .background(Color(.systemBlue))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SensorButton: View {
    
    var flag: Bool
    //var model: WatchConnectivityManager
    var body: some View {
        
        if (flag == true) {
            Text("ON")
                .bold()
                .font(.title2)
                .frame(width: 150, height: 200)
                .background(Color(.systemGreen))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        else {
            Text("OFF")
                .bold()
                .font(.title2)
                .frame(width: 150, height: 200)
                .background(Color(.systemRed))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct RingSensorButton: View {
    
    var state: Bool
    //var model: WatchConnectivityManager
    var body: some View {
        
        if (state == true) {
            Text("ON")
                .bold()
                .font(.title2)
                .frame(width: 150, height: 200)
                .background(Color(.systemGreen))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        else {
            Text("OFF")
                .bold()
                .font(.title2)
                .frame(width: 150, height: 200)
                .background(Color(.systemRed))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct PictureModeCircle: View {
    
    @Binding var flag: Bool
    //var type: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    flag.toggle()
                }, label: {
                    if (flag == false) {
                        Image(systemName: "circle.fill")
                    }
                    else {
                        Image(systemName: "circle")
                    }
                })
                Button(action: {
                    flag.toggle()
                }, label: {
                    Text("pre")
                })
            }
            
            HStack {
                Button(action: {
                    flag.toggle()
                }, label: {
                    if (flag == true) {
                        Image(systemName: "circle.fill")
                    }
                    else {
                        Image(systemName: "circle")
                    }
                })
                Button(action: {
                    flag.toggle()
                }, label: {
                    Text("post")
                })
            }
        }
        .foregroundColor(.gray)
    }
}

struct CheckWatchConnection: View {
    
    var model: WatchConnectivityManager
    @Binding var reachable: String
    
    var body: some View {
        VStack {
            Text("\(reachable)")
            Button(action: {
//                if model.session.isReachable {
//                    reachable = "Connected"
//                    HapticManager.instance.notification(type: .success)
//                }
//                else {
                //print("sensorFlag is set to: \(model.sensorFlag)")
                reachable = "Disconnected"
                startWatchApp(model.session) { launched in
                    if launched && model.session.isReachable {
                        reachable = "Connected"
                        HapticManager.instance.notification(type: .success)
                    }
                    else {
                        HapticManager.instance.notification(type: .error)
                    }
                }
                
            }) {
                Text("Update")
            }
        }
    }
}

func startWatchApp(_ session: WCSession, completion: @escaping (Bool) -> Void) {
    if session.activationState == .activated && session.isWatchAppInstalled {
        let workoutConfiguration = HKWorkoutConfiguration()
        HKHealthStore().startWatchApp(with: workoutConfiguration, completion: { (success, error) in
            // Handle errors
            if !success {
                print("starting watch app failed with error: \(String(describing: error))")
                completion(false)
            }
            else {
                print("startWatchApp function passed!")
                completion(true)
               
                
            }
        })
                                
    }
    else {
        print("watch not active or not installed")
        completion(false)
    }
}


struct IDInputView: View {
    
    @Binding var participantID: String
    
    var body: some View {
        HStack() {
            Text("Participant ID: ")
            TextField("Input your participant ID", text: $participantID)
                .border(Color.gray, width: 50.0)
                .onSubmit {
//                    WCSession.default.sendMessage(["participantID" : self.participantID], replyHandler: { reply in
//                        print(reply)
//                    },
//                    errorHandler: { (error) in
//                        print("Error with ID change!")
//                    })
                    
                    DispatchQueue.main.async {
                        do {
                            try WCSession.default.updateApplicationContext(["participantID" : self.participantID])
                            print("Application Context Updated!")
                        } catch {
                            print("Failed to send application context: \(error.localizedDescription)")
                        }
                        
                    }
                }
        }
    }
}


