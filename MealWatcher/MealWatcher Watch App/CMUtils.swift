//
//  CMUtils.swift
//  dataLogger WatchKit Extension
//
//  Created by Cameron Burroughs on 3/22/22.
//

import Foundation
import CoreMotion
import HealthKit
import WatchKit

struct sensorParam {
    
    // gyro values
    var gyrox: Float32
    var gyroy: Float32
    var gyroz: Float32
    
    // acc values
    var accx: Float32
    var accy: Float32
    var accz: Float32
    
    var magFieldx: Float32
    var magFieldy: Float32
    var magFieldz: Float32
    
    var attitudex: Float32
    var attitudey: Float32
    var attitudez: Float32
    var attitudew: Float32
    
    var linaccx: Float32
    var linaccy: Float32
    var linaccz: Float32
    
    var time: UInt64
}

// Class CMutils implements functionality using CoreMotion framework
class CMUtils: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
//class CMUtils: NSObject {
    //let file_manager = LocalFileManager.instance
    let manager = CMMotionManager()
    let healthStore = HKHealthStore()
    let queue = OperationQueue()
    
    var WKsession: HKWorkoutSession? = nil
    var builder: HKLiveWorkoutBuilder? = nil
    
    let interval = 1.0/Double(samplingRate)
    @Published var timeOffset: UInt64?
    let degreeConv = 180.0/Double.pi
    var outputStream: OutputStream?
    let vm = FileManagerViewModelWatch()
    @Published var currentURL: URL?

    
    
    override init() {
    }
    
    // Requests healthstore access, establishes bckgnd session to record sensor data
    // Documentation for setting up a background workout session found here
    //https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/running_workout_sessions
    
    func startWorkoutSession() {
        print("Initializing new workout session")
        // if session is already started, do nothing
        if WKsession != nil {
            return
        }

        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("HKHealthScore Unavailable!")
        }

        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // Request authorization for those quantity types.
        print("Requesting healthstore authorization ... ")
        self.healthStore.requestAuthorization(toShare: typesToShare, read: nil, completion: { (success, error) in
                guard success else {
                    fatalError("AUTHORIZATION ERROR: \(String(describing: error))")
                }

                // Create a workout configuration object
                // ** Activity and location type have no effect on sensor data
                let WKconfig = HKWorkoutConfiguration()
                WKconfig.activityType = .walking
                WKconfig.locationType = .indoor

                do {
                    // Initialize a new workout session with healthstore and configuration object
                    self.WKsession = try HKWorkoutSession(healthStore: self.healthStore,
                                                          configuration: WKconfig)

                    // Initialize reference to builder object from our workout session
                    self.builder = self.WKsession?.associatedWorkoutBuilder()
                } catch {
                    print(error)
                    self.WKsession = nil
                    return
                }


                // Create an HKLiveWorkoutDataSource object and assign it to the workout builder.
                self.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore,
                                                                   workoutConfiguration: WKconfig)

                // Assign delegates to monitor both the workout session and the workout builder.
                self.WKsession?.delegate = self
                self.builder?.delegate = self

                // Start session and builder collection of health data
                self.WKsession?.startActivity(with: Date())
                self.builder?.beginCollection(withStart: Date()) { (success, error) in
                    guard success else {
                        print("Unable to begin builder collection of data: \(String(describing: error))")
                        return
                        //fatalError("Unable to begin builder collection of data: \(String(describing: error))")
                    }

                    // Indicate workout session has begun
                    print("Workout activity started, builder has begun collection")
                }
        })

    }

    // Ends the current background workout session and collection of data
    func endWorkoutSession() {
        print("Ending Workout Session ")
        guard let session = WKsession else {return}
        session.stopActivity(with: Date())
        session.end()
    }
    
    // Sets struct to all zeros, diagnostic to see where we are/aren't getting data
    func zeroParams() -> sensorParam {
        let sensorData = sensorParam(gyrox: 0, gyroy: 0, gyroz: 0, accx: 0, accy: 0, accz: 0, magFieldx: 0, magFieldy: 0, magFieldz: 0, attitudex: 0, attitudey: 0, attitudez: 0, attitudew: 1.0, linaccx: 0, linaccy: 0, linaccz: 0, time: 0)
        return sensorData
    }
    
    // Begins data retrieval from sensors and appends to csv file in background
    func startUpdates(filename: String) {
        startWorkoutSession()
        self.currentURL = vm.getDataFileURL(timeStamp: filename)
        guard let currentURL = currentURL else {return}
        self.startRecording(fileURL: currentURL)
        

        // Verify device-motion service is available on device
        if !manager.isDeviceMotionAvailable {
            fatalError("Device motion not available.")
        }

        // Set sampling rate
        let interval = 1/Double(samplingRate)
        print("Interval is: ", interval)
        
        manager.deviceMotionUpdateInterval = interval
        
        print("Device motion interval:", manager.deviceMotionUpdateInterval)
        // Continually gets motion data and updates CSV file
        manager.startDeviceMotionUpdates(to: queue){ (data,err) in
            if err != nil {
                print("Error starting Device Updates: \(err!)")
            }
            var sensorData = self.zeroParams()
            
            let gravity = data!.gravity
            if data != nil {
                sensorData.accx = Float(data!.userAcceleration.x + gravity.x)
                sensorData.accy = Float(data!.userAcceleration.y + gravity.y)
                sensorData.accz = Float(data!.userAcceleration.z + gravity.z)
                sensorData.gyrox = Float(data!.rotationRate.x * self.degreeConv)
                sensorData.gyroy = Float(data!.rotationRate.y * self.degreeConv)
                sensorData.gyroz = Float(data!.rotationRate.z * self.degreeConv)
                
                sensorData.linaccx = Float(data!.userAcceleration.x)
                sensorData.linaccy = Float(data!.userAcceleration.y)
                sensorData.linaccz = Float(data!.userAcceleration.z)
                
                sensorData.attitudex = Float(data!.attitude.quaternion.x)
                sensorData.attitudey = Float(data!.attitude.quaternion.y)
                sensorData.attitudez = Float(data!.attitude.quaternion.z)
                sensorData.attitudew = Float(data!.attitude.quaternion.w)
                
                sensorData.magFieldx = Float(data!.magneticField.field.x)
                sensorData.magFieldy = Float(data!.magneticField.field.y)
                sensorData.magFieldz = Float(data!.magneticField.field.z)

                
                let CMTimeStamp = data!.timestamp
                if self.timeOffset == nil {
                    let since1970 = Date().timeIntervalSince1970 // Get the time interval since Jan 1, 1970
                    let timeInMilliseconds = UInt64(since1970 * 1000) // Convert the time interval to milliseconds
                    self.timeOffset = timeInMilliseconds - UInt64(CMTimeStamp*1000)
                }
                sensorData.time = UInt64(CMTimeStamp*1000)+(self.timeOffset ?? 0)
                //print("timestamp: \(sensorData.time)")
//                print("Acc: \(sensorData.accx), \(sensorData.accy), \(sensorData.accz) - Gyro: \(sensorData.gyrox), \(sensorData.gyroy), \(sensorData.gyroz)")
//                let uptime = ProcessInfo.processInfo.systemUptime
//                print("Core Motion Timestamp: \(sensorData.time), Time since last boot (seconds): \(uptime), Offset: \(sensorData.time-uptime)")
//                self.file_manager.updateDataFile(filename: filename, withInfo: sensorData)
                let binaryData = Data(bytes: &sensorData, count: MemoryLayout<sensorParam>.size)
                self.writeToStream(data: binaryData)
                
            }
        }
        
        
        print("Device motion interval:", manager.deviceMotionUpdateInterval)
        
    }
    
    // Stops device motion updates
    func stopUpdates(filename: String) {
        print("Stopping device motion updates ...")
        self.timeOffset = nil
        //self.file_manager.closeFile(filename: filename)
        self.stopRecording()
        manager.stopDeviceMotionUpdates()
        endWorkoutSession()
    }
    
    // Handles sensor data struct, formats to string to write to csv
    // Change how data is written to file here
    func sortData (usingData params: sensorParam) -> String {
        return "\(params.time),\(params.accx),\(params.accy),\(params.accz),\(params.gyrox),\(params.gyroy),\(params.gyroz),\(params.linaccx),\(params.linaccy),\(params.linaccz),\(params.attitudex),\(params.attitudey),\(params.attitudez),\(params.attitudew),\(params.magFieldx),\(params.magFieldy),\(params.magFieldz)\n"
    }
    
    
    // Extra stubs&methods needed (code inside is suggested from apple dev forums,
    // but we dont end up using any of it
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for _ in collectedTypes {

                DispatchQueue.main.async() {
                    // Update the user interface.
                }
            }
    }

    // Necessary func for workout builder
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //let lastEvent = workoutBuilder.workoutEvents.last

            DispatchQueue.main.async() {
                // Update the user interface here.
            }
    }

    // Necessary func for workout builder
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Wait for the session to transition states before ending the builder.

        if toState == .ended {
            print("The workout has now ended.")
            builder?.endCollection(withEnd: Date()) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    // I had to add this step
                    //self.session = nil
                }
            }
        }
    }

    // Necessary func for workout builder
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //code
    }
    
    // Function to write data to the stream
    func writeToStream(data: Data) {
        guard let stream = self.outputStream else {
            print("Stream is not open")
            return
        }
        
        let buffer = [UInt8](data)
        let bytesWritten = stream.write(buffer, maxLength: buffer.count)
        if bytesWritten < 0 {
            print("Write error")
        }
    }
    
    // Function to start recording
    func startRecording(fileURL: URL) {
        self.outputStream = OutputStream(url: fileURL, append: true)
        self.outputStream?.open()
    }
    
    // Function to stop recording
    func stopRecording() {
        self.outputStream?.close()
    }
    
    
    
}




