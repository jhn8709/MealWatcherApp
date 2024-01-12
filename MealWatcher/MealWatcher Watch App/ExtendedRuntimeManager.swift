//
//  ExtendedRuntimeManager.swift
//  Bite Count WatchKit App
//
//  Created by Jimmy Nguyen on 7/27/23.
//  Copyright © 2023 Clemson University. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class ExtendedRuntimeManager: NSObject, WKExtendedRuntimeSessionDelegate, ObservableObject {
    
    @Published var newestTimeStamp: String = "Unknown"
    let cmutils = CMUtils()
    @Published var vmWatch = FileManagerViewModelWatch()
    // MARK:- Extended Runtime Session Delegate Methods
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Track when your session starts.
        print("Extended runtime session is starting")
    }


    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Finish and clean up any tasks before the session ends.
        print("Extended runtime session is expired")
        cmutils.stopUpdates(filename: newestTimeStamp)
        print("Attempting to send CSV file")
        guard let fileURL = vmWatch.getDataFileURL(timeStamp: newestTimeStamp) else {return}
        if WCSession.default.isReachable {
            print(fileURL)
            WCSession.default.transferFile(fileURL, metadata: nil)
        } else {
            print("iOS app not reachable")
        }
    }
        
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Track when your session ends.
        print("Extended runtime session is ending")
        // Also handle errors here.
        
        print("didInvalidateWithReason: \(reason)")
        
        if error != nil {
            print("Errors Encountered!")
            //print(error)
        }
        else {
            return
        }
    }
    
}


