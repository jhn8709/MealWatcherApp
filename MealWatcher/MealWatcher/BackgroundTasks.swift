//
//  BackgroundTasks.swift
//  MealWatcher
//
//  Created by Jimmy Nguyen on 12/11/23.
//

import Foundation
import SwiftUI
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @Published private var backgroundTaskID: UIBackgroundTaskIdentifier?
    @Published private var timer: Timer?
    @Published private var counter = 0
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Your app initialization code
//        return true
//    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register a background task identifier
        print("UIApplication Setup")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.SmartRingStudy.MealWatcher.bg_update", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // App entered the background
        // Optionally, perform tasks when app enters the background
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // App is transitioning from background to foreground (inactive)
        // Optionally, perform tasks when app becomes active
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // App is about to terminate
        // Optionally, perform cleanup tasks
    }
        
    func handleBackgroundTask(task: BGProcessingTask) {
        // Perform your background task here
        // ...
        // Invalidate the existing timer, if any
        print("Starting Background Task")
        self.timer?.invalidate()
        // Create a new timer that fires every 1 second
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Update the counter or perform any action you want
            self.counter += 1
            
            // Stop the time after 2 minutes
            if self.counter >= 120 {
                print("Count for 2 minutes")
                self.timer?.invalidate()
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.SmartRingStudy.MealWatcher.bg_update")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false

        do {
            print("Scheduling Background Task")
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Error scheduling background task: \(error.localizedDescription)")
        }
    }

}

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    var bluetoothViewModel = BluetoothViewModel.instance

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func startBackgroundTask(ringUUID: UUID) {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }

        // Start your Bluetooth operations here
        print("Connecting to bluetooth device in background")
        bluetoothViewModel.connectWithUUID(ringUUID: ringUUID)
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
