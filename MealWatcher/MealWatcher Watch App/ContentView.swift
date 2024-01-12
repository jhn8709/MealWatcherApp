//
//  ContentView.swift
//  L1 Demo
//
//  Created by Jimmy Nguyen on 6/4/23.
//

import SwiftUI
import WatchConnectivity
import HealthKit
import WatchKit

class ExtensionDelegate: NSObject, WKApplicationDelegate, WKExtensionDelegate {

    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    override init(){
        super.init()
    }
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.

    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ workoutConfiguration: HKWorkoutConfiguration)
    {
        //presentAlert()
        WKInterfaceDevice.current().play(.retry)

    }


}


struct ContentView: View {
    
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @StateObject private var vmWatch = FileManagerViewModelWatch()
    
    @State var extendedSession = WKExtendedRuntimeSession()
    @State var extendedDelegate = ExtendedRuntimeManager()

    //State private var appDelegate = ExtensionDelegate()
    //@State var appStartDelegate = ExtensionDelegate()
    
    /* CSV File management */
    let cmutils = CMUtils()
    var filePath: String = ""
    var fileName: String = ""
    @State private var newestTimeStamp: String = "Unknown"
    @State var dataCount = 0
    @State var sensorFlag: Bool = false
    @AppStorage("storedID") var participantID: String = "P9999"
    
    var body: some View {
        
        VStack {
            Text(participantID)
//            Text(connectivityManager.messageText)
//            Button("Hello World!", action: {
//              connectivityManager.send("Hello World!\n\(Date().ISO8601Format())")
//            })
//            .alert(item: $connectivityManager.notificationMessage) { message in
//                Alert(title: Text(message.text),
//                       dismissButton: .default(Text("Dismiss")))
//            }
            Button {
                // sensor on/off toggle
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
                
//                guard WCSession.default.activationState == .activated else {
//                    print("Session not activated")
//                    return //handleSessionUnactivated(with: commandStatus)
//                }
//                do {
//                    try WCSession.default.updateApplicationContext(["sensor-flag" : true])
//                } catch {
//                    print("Error updating application context!")
//        
//                }
                
                //connectivityManager.sensorFlag.toggle()
                
            } label:  {
                SensorButton(flag: connectivityManager.sensorFlag)
            }
            Button(action: {
                dataCount = vmWatch.listSize()
            },label: {
                Text("File Count \(dataCount)")
                    .foregroundColor(.purple)
            })
        }
        .onChange(of: connectivityManager.sensorFlag) { flag in
            if flag == true {
                print("start logging")
                //startExtendedSession()
                startLogging()
            }
            else {
                print("stop logging")
                //endExtendedSession()
                stopLogging()
            }
        }
        .onChange(of: connectivityManager.participantID) { changeID in
            if changeID != "P9999" {
                participantID = changeID
            }
        }
        .onChange(of: connectivityManager.deleteData) { delete in
            if delete == true {
//                guard let dataFileURL = connectivityManager.fileURL else {
//                    print("Error: No file found")
//                    return
//                }
                guard let fileURL = vmWatch.getDataFileURL(timeStamp: newestTimeStamp) else {return}
                vmWatch.deleteDataFile(dataURL: fileURL)
                connectivityManager.deleteData = false
            }
        }
    }


    func startLogging() {
        print("Starting logging ...")
        startExtendedSession()
        let date = Date()
        let df = DateFormatter()
        //df.dateFormat = "MM-dd-yyyy-hh-mm-a"
        df.dateFormat = "yyyyMMddHHmmss"
        print(df.string(from: date))
        newestTimeStamp = participantID+"-"+df.string(from: date)
        newestTimeStamp += "-watch"
        // Start sending updates to file
        extendedDelegate.newestTimeStamp = self.newestTimeStamp
        cmutils.startUpdates(filename: newestTimeStamp)
    }
    
    func stopLogging() {
        print("Stopping logging ...")
        
        // Stop updating the file
        cmutils.stopUpdates(filename: newestTimeStamp)
        endExtendedSession()
        // create record ID from date & time
//        var recordID = getDate()
//        recordID.append("_\(getTime(ms: false))")
        sendData(timeStamp: newestTimeStamp)
    }
    
    func sendCSV(timeStamp: String) {
        print("Attempting to send CSV file")
        guard let fileURL = vmWatch.getCSVFileURL(timeStamp: newestTimeStamp) else {return}
        if WCSession.default.isReachable {
            print(fileURL)
            WCSession.default.transferFile(fileURL, metadata: nil)
        } else {
            print("iOS app not reachable")
        }
    }
    
    func sendData(timeStamp: String) {
        print("Attempting to send CSV file")
        guard let fileURL = vmWatch.getDataFileURL(timeStamp: newestTimeStamp) else {return}
        if WCSession.default.isReachable {
            print(fileURL)
            WCSession.default.transferFile(fileURL, metadata: nil)
        } else {
            print("iOS app not reachable")
        }
    }
    
    func startExtendedSession() {
        // Assign the delegate.
        guard extendedSession.state != .running else { return }
        // create or recreate session if needed
        if extendedSession.state == .invalid {
            extendedSession = WKExtendedRuntimeSession()
            extendedSession.delegate = extendedDelegate
        }
        print("Bite session starting")
        
        extendedSession.start()
    }

    func endExtendedSession() {
        print("Attempting to end session")
        if extendedSession.state == .running {
            extendedSession.invalidate()
        }
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SensorButton: View {
    var flag: Bool
    var body: some View {
        
        if (flag == true) {
            Text("ON")
                .bold()
                .font(.title2)
                .frame(width: 185, height: 50)
                .background(Color(.green))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        else {
            Text("OFF")
                .bold()
                .font(.title2)
                .frame(width: 185, height: 50)
                .background(Color(.red))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}
