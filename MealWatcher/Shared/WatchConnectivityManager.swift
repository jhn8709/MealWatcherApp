//
//  WatchConnectivityManager.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 6/11/23.
//

import Foundation
import WatchConnectivity

struct NotificationMessage: Identifiable {
    let id = UUID()
    let text: String
}

class WatchConnectivityManager: NSObject, ObservableObject {
    
    static let shared = WatchConnectivityManager()
    var session: WCSession
    @Published var notificationMessage: NotificationMessage? = nil
    @Published var messageText = ""
    @Published var sensorFlag: Bool = false
    @Published var fileURL: URL? = nil
    @Published var fileData: Data?
    @Published var participantID: String = "P9999"
    @Published var deleteData: Bool = false
    
    

    
    init(session: WCSession = .default) {
        self.session = WCSession.default
        super.init()
        self.session.delegate = self
        self.session.activate()
        print("Finished initialization")
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            //print("Finished initialization")
        }
    }
    
    private let kMessageKey = "notif"
        
    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif
        
        WCSession.default.sendMessage([kMessageKey : message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("incoming message")
        if let notificationText = message["notif"] as? String {
            print("Notification message received")
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
            return
        }
        if message["sensor-flag"] is Bool {
            DispatchQueue.main.async {
                self.sensorFlag.toggle()
                print("Message received and new flag value is: \(self.sensorFlag)")
                
                replyHandler([
                            "response": "properly formed message!",
                            "sensor-flag": self.sensorFlag
                        ])
            }
            return
        }
        if message["participantID"] is String {
            DispatchQueue.main.async {
                self.participantID = message["participantID"] as! String
            }
            print("Message received and new ID value is: \(self.participantID)")
            
            replyHandler([
                "response" : "properly formed message!",
                "participantID" : self.participantID
                ])
        }
        print("Error receiving message!")
        replyHandler([
                    "response": "improperly formed message!"
                ])
    }
    /* This function should be used to handle all relevant data between the two programs*/
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        // Handle the received data
        print("Application Context Received")
        if applicationContext["sensor-flag"] is Bool {
            DispatchQueue.main.async {
                self.sensorFlag.toggle()
                print("Application Context Read!")
            }
        }
        if applicationContext["participantID"] is String {
            DispatchQueue.main.async {
                self.participantID = applicationContext["participantID"] as! String
            }
            print("Message received and new ID value is: \(self.participantID)")
        }
    
    }
    
    // Implement the session(_:didReceiveFile:) method to handle the received file
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.async {
            self.fileURL = file.fileURL
            print("Received fileURL")
            guard let receivedFileContent = try? Data(contentsOf: file.fileURL) else {
                print("Data could not be received")
                return
            }
            print("Received data from fileURL")
            self.fileData = receivedFileContent
        }
        // Handle the received file URL
    }
    
    func session(_ session: WCSession, didReceiveError error: Error) {
        // Handle the error
        print("Watch Connectivity error: \(error.localizedDescription)")
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            // Handle the error
            print("File transfer failed: \(error.localizedDescription)")
        } else {
            // File transfer completed successfully
            print("File transfer completed for \(fileTransfer.file.fileURL.lastPathComponent)")
            DispatchQueue.main.async {
                self.deleteData.toggle()
            }
        }
    }



    
}


