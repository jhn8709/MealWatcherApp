//
//  RingManager.swift
//  MealWatcher
//
//  Created by Jimmy Nguyen on 10/9/23.
//

import Foundation

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

func decodeCOBS(_ encodedData: [UInt8]) -> [UInt8]? {
    var decodedData: [UInt8] = []
    let overheadByte: UInt8 = encodedData[0]
    var nextZero = overheadByte
    var counter = 0
    
    for byte in encodedData[1...] {
        if byte == 0 {
            break
        }
        counter += 1
        if counter == nextZero {
            nextZero = byte
            decodedData.append(0)
            counter = 0
        }
        else {
            decodedData.append(byte)
        }
    }
    //print(decodedData.count)
    if decodedData.isEmpty || decodedData.count < 109 {
        return nil
    }

    return decodedData
}

func littleEndianHexToFloat(_ bytes: [UInt8]) -> Float {
    // Ensure the byte array has 4 bytes
//        guard bytes.count == 4 else {
//            print("Byte count is incorrect!")
//            return nil
//        }
    // Interpret the bytes as a little-endian Float
    let outputValue = Float(bitPattern: UInt32(bytes[0]) |
                                         (UInt32(bytes[1]) << 8) |
                                         (UInt32(bytes[2]) << 16) |
                                         (UInt32(bytes[3]) << 24))
    return outputValue
}

func getTimeStamp(_ bytes: [UInt8]) -> UInt64 {
    let timestamp_us =
        UInt64(bytes[0]) |
        (UInt64(bytes[1]) << 8) |
        (UInt64(bytes[2]) << 16) |
        (UInt64(bytes[3]) << 24) |
        (UInt64(bytes[4]) << 32) |
        (UInt64(bytes[5]) << 40) |
        (UInt64(bytes[6]) << 48) |
        (UInt64(bytes[7]) << 56)
    
    return timestamp_us
}

// Sets struct to all zeros, diagnostic to see where we are/aren't getting data
func zeroParams() -> sensorParam {
    let sensorData = sensorParam(gyrox: 0, gyroy: 0, gyroz: 0, accx: 0, accy: 0, accz: 0, magFieldx: 0, magFieldy: 0, magFieldz: 0, attitudex: 0, attitudey: 0, attitudez: 0, attitudew: 1.0, linaccx: 0, linaccy: 0, linaccz: 0, time: 0)
    return sensorData
}



