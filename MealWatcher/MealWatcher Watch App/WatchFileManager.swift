//
//  FileManager.swift
//  FileManagerDemo
//
//  Created by Jimmy Nguyen on 6/19/23.
//

import Foundation
import SwiftUI

public class LocalFileManager {
    
    static let instance = LocalFileManager()
    let mainFolderName = "BiteCounter_Data"
    
    init() {
        createMainFolderIfNeeded()
    }
    
    func createMainFolderIfNeeded() {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .path else {
            return
        }
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                print("Success creating folder")
            } catch let error {
                print("Error creating folder \(error)")
            }
        }
    }

    /* delete all local data */
    func deleteMainFolder () {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("BiteCounter_Data")
            .path else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("Success deleting folder")
        } catch let error {
            print("Error deleting folder. \(error)")
        }
    }
    
    func getPathForCSV(fileName: String) -> URL? {
        
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .appendingPathComponent("\(fileName).csv") else {
            print("Error getting path")
            return nil
        }
        //print(path.path)
        return path
    }
    
    func deleteCSV(name: String) -> String {
        
        guard let path = getPathForCSV(fileName: name),
              FileManager.default.fileExists(atPath: path.path) else {
            return "Error getting path"
            
        }
        
        do {
            try FileManager.default.removeItem(at: path)
            return "Successfully deleted."
        } catch let error {
            return "Error deleting image. \(error)"
        }
    }
    
    func printPath() -> Int {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .path else {
            return 0
        }
        //let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path)
            print("Folder Contents: \(folderContents)")
            print("The folder contains \(folderContents.count) folders")
            return folderContents.count
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return 0
        }
    }
    
    func updateCSV(filename: String, withInfo info: String) {
        
        // Create file in directory, get path of file
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .appendingPathComponent("\(filename).csv") else {
            print("Error getting path")
            return
        }

        // Generate url to filepath
        let fileURL = NSURL(fileURLWithPath: path.path)
        
        
        guard let data = info.data(using: String.Encoding.utf8) else {return}
       
        // If file exists, go to end of file, adds encoded info->data
        if FileManager.default.fileExists(atPath: (fileURL as URL).path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL as URL) {
                       fileHandle.seekToEndOfFile()
                       fileHandle.write(data)
                       fileHandle.closeFile()
                   }
            //print("updating CSV")
        } else {
            // File DNE at path, adds header & info to new file
            var header = Config.CSVHeader
            header.append(info)
            
            // Attempt to create new file at provided fileURL
            do {
                try header.write(to: fileURL as URL,
                                    atomically: true,
                                    encoding: String.Encoding.utf8)
            } catch {
                print("Failed to write file to fileURL: \(fileURL). Error: \(error)")
            }
        }
    }
    
    func updateDataFile(filename: String, withInfo info: sensorParam) {
        
        // Create file in directory, get path of file
        guard let path = getPathForData(fileName: filename) else {return}
        
        do {
            // Check if the file already exists. If not, create it.
            if !FileManager.default.fileExists(atPath: path.path) {
                FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
            } 
            // Open the file for writing (creating it if it doesn't exist)
            let fileHandle = try FileHandle(forWritingTo: path)
            // Seek to the end of the file
            fileHandle.seekToEndOfFile()
            // Data to write
            var sensorData = info // Create an instance of your data struct
            // Convert the data to binary
            var binaryData = Data()
            binaryData.append(Data(bytes: &sensorData, count: MemoryLayout<sensorParam>.size))
            // Write the binary data to the end of the file
            fileHandle.write(binaryData)
            // Close the file when you're done
            //fileHandle.closeFile()
        } catch {
            print("Error writing to file: \(error)")
        }
    }
    
    func closeFile(filename: String) {
        // Create file in directory, get path of file
        guard let path = getPathForData(fileName: filename) else {return}
        
        do {
            let fileHandle = try FileHandle(forWritingTo: path)
            fileHandle.closeFile()
            print("Successfully closed the file")
        } catch {
            print("Error writing to file: \(error)")
        }
    }
    
    func getPathForData(fileName: String) -> URL? {
        
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .appendingPathComponent("\(fileName).data") else {
            print("Error getting path")
            return nil
        }
        //print(path.path)
        return path
    }
    
    func deleteData(dataURL: URL) {
        
//        guard let path = getPathForData(fileName: name),
//              FileManager.default.fileExists(atPath: path.path) else {
//            return "Error getting path"
//            
//        }
//        
        do {
            try FileManager.default.removeItem(at: dataURL)
            print("Successfully deleted.")
        } catch let error {
            print("Error deleting image. \(error)")
        }
    }
    
}

class FileManagerViewModelWatch: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var infoMessage: String = ""
    @Published var folderCount: Int = 0
    let manager = LocalFileManager.instance
    //@Published var currentTimeStamp: String = ""
    
    
    init () {
    }
    
    func deleteCSV(fileName: String) {
        infoMessage = manager.deleteCSV(name: fileName)
    }
    
    func listSize() -> Int {
        folderCount = manager.printPath()
        return folderCount
    }
    
    func getCSVFileURL(timeStamp: String) -> URL? {
        guard let fileURL = manager.getPathForCSV(fileName: timeStamp) else {
            print("Error getting CSV file URL")
            return nil
        }
        return fileURL
    }
    
    func getDataFileURL(timeStamp: String) -> URL? {
        guard let fileURL = manager.getPathForData(fileName: timeStamp) else {
            print("Error getting data file URL")
            return nil
        }
        return fileURL
    }
    
    func deleteDataFile(dataURL: URL) {
        manager.deleteData(dataURL: dataURL)
    }
}
