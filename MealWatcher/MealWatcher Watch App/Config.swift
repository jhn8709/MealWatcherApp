//
//  Config.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 3/11/22.
//
import SwiftUI
public var samplingRate = 100

enum Config {
    // Define the header used for the csv file
    static let CSVHeader = "Time,accx,accy,accz,gyrox,gyroy,gyroz\n"
    
    // Define a single file name to manipulate during storing data
    // Auto-deletes file after uploading to cloudkit
    static let CSVFilename = "sensordata.csv"
}

// Retrieve current date as string
func getDate() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-YYYY"
    return formatter.string(from: currentDateTime)
}

// Retrieve current Timestamp as string
func getTime(ms: Bool) -> String {
    let currentDateTime = Date()
    
    // Format "HH" indicates 24-hour, "hh" 12-hour, "SSSS" for ms
    let formatter = DateFormatter()
    if ms {
        formatter.dateFormat = "HH:mm:ss.SSS"
    } else {
        formatter.dateFormat = "HH-mm-ss"
    }
    
    // Return time
    return formatter.string(from: currentDateTime)
}

    

