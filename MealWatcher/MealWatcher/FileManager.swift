//
//  FileManager.swift
//  FileManagerDemo
//  
//  This file is used to manage all the data that needs to be stored locally. 
//
//  Created by Jimmy Nguyen on 6/19/23.
//

import Foundation
import SwiftUI

class LocalFileManager {
    
    static let instance = LocalFileManager()
    let mainFolderName = "MealWatcher_Data"
    
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
            .appendingPathComponent(mainFolderName) else {
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            // Iterate through the contents and delete each item
            for itemURL in contents {
                try FileManager.default.removeItem(at: itemURL)
            }
            print("Success deleting contents")
        } catch let error {
            print("Error deleting contents. \(error)")
        }
    }
    
    func addNewFolder(folderName: String) {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            .appendingPathComponent(folderName)
            .path else {
            return
        }
        print("new folder path:", path)
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                print("Success creating folder")
            } catch let error {
                print("Error creating folder \(error)")
            }
        }
    }
    
    func saveImage(image: UIImage, imageName: String) -> String { //folderName: String) -> String {
        
        guard let data = image.jpegData(compressionQuality: 1.0)
        else {
            print("Error getting data.")
            return "Error getting data."
        }
        
        guard let path = getPathForImage(imageName: imageName)
        else {
            print("Error getting path")
            return "Error getting path."
        }
        print(path)
        do {
            try data.write(to: path)
            //print(path)
            return "Success saving"
        } catch let error {
            return "Error saving. \(error)"
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        
        guard let path = getPathForImage(imageName: imageName)?.path,
              FileManager.default.fileExists(atPath: path) else {
            print("Error getting path")
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    func getPathForImage(imageName: String) -> URL? { //folderName: String) -> URL? {
        
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            //.appendingPathComponent(folderName)
            .appendingPathComponent("\(imageName).jpg") else {
            print("Error getting path")
            return nil
        }
        //print(path)
        return path
    }
    
    func deleteImage(name: String) -> String {
        
        guard let path = getPathForImage(imageName: name),
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
            .appendingPathComponent(mainFolderName) else {
            return 0
        }
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            //print("Folder Contents: \(folderContents)")
            //print("The folder contains \(folderContents.count) files")
            return folderContents.count
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return 0
        }
    }
    
    func sortMainFolder() -> [String]? {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName) else {
            return nil
        }
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            let sortedFolderContents = folderContents.sorted { dateString1, dateString2 in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                if let date1 = formatter.date(from: dateString1), let date2 = formatter.date(from: dateString2) {
                    return date1 > date2
                } else {
                    return false
                }
            }
            print("Sorted folder contents: \(sortedFolderContents)")
            return sortedFolderContents
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getFolderName(index: Int) -> (String?) {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName) else {
            return nil
        }
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            let folderName = folderContents[index]
            print("Folder name: \(folderName)")
            return folderName
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getFolderPath(/*folderName: String*/) -> URL? {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName) else {
            //.appendingPathComponent(folderName) else {
            print("Error getting path")
            return nil
        }
        return path
    }
    
    func getFolderSize(/*folderName: String*/) -> Int? {
        guard let path = getFolderPath() else {return nil}
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            print("Data folder: contains \(folderContents.count) files")//folders")
            return folderContents.count
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    func getPathForCSV(/*folderName: String,*/fileURL: URL) -> URL? {
        guard let path = getFolderPath() else {return nil}
        let destinationURL = path.appendingPathComponent(fileURL.lastPathComponent)
        return destinationURL
    }
    
    func importCSV(/*folderName: String,*/fileURL: URL, data: Data) {

        guard let path = getPathForCSV(fileURL: fileURL) else {return}
        //print(path)
        do {
            try data.write(to: path)
            print("File saved at: \(path)")

        } catch {
            // Error occurred while saving the file
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
    
    func fetchData(/*folderName: String,*/index: Int) -> (data: Data?, fileName: String?)? {
        guard let path = getFolderPath() else {return (nil,nil)}
        do {
            let folderContents = try FileManager.default.contentsOfDirectory(atPath: path.path)
            let itemName = folderContents[index]
            let itemPath = path.appendingPathComponent(itemName)
            let data = try Data(contentsOf: itemPath)
            return (data, itemName)
            // Convert the itemURL to URL if necessary
        } catch {
            print("Error reading folder contents: \(error.localizedDescription)")
            return (nil, nil)
        }
    }
    
    func getPathForSurvey(surveyName: String) -> URL? { //folderName: String) -> URL? {
        
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName)
            //.appendingPathComponent(folderName)
            .appendingPathComponent(surveyName) else {
            print("Error getting path")
            return nil
        }
        return path
    }
    
    func updateDataFile(filename: String, withInfo info: sensorParam) {
        
        // Create file in directory, get path of file
        guard let path = getPathForData(fileName: filename) else {return}
        do {
            // Check if the file already exists. If not, create it.
            if !FileManager.default.fileExists(atPath: path.path) {
                FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
            }
            // Open the file for writing
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
    
    func getMainDirectoryFilePaths() -> [URL]? {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(mainFolderName) else {
            print("Error getting path")
            return nil
        }
        
        do {
            // Get the contents of the directory
            let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            
            return fileURLs
        } catch {
            // Handle the error, e.g., print an error message
            print("Error: \(error)")
            return nil
        }
    }
    
    func deleteFile(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
            print("File deleted successfully.")
        } catch {
            throw error
        }
    }
    
    
    
}

class FileManagerViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var infoMessage: String = ""
    @Published var folderCount: Int = 0
    let imageName: String = "3Falls_Niagara"
    let manager = LocalFileManager.instance
    //@Published var currentTimeStamp: String = ""
    
    
    init () {
        getImageFromAssetsFolder()
        //image = getImageFromFileManager(pictureName: "TestPicture")
        //getImageFromFileManager(pictureName: "TestPicture")
    }
    
    func createNewFolder(timeStamp: String)
    {
        manager.addNewFolder(folderName: timeStamp)
    }
    
    func getImageFromAssetsFolder() {
        image = UIImage(named: imageName)
        //image = UIImage(systemName: "fork.knife.circle.fill")
    }
    
    func getImageFromFileManager(timeStamp: String, PrePostFlag: Bool) -> UIImage? {
        var pictureName: String = timeStamp
        if PrePostFlag {
            pictureName = timeStamp + "-post"
        }
        else {
            pictureName = timeStamp + "-pre"
        }
        guard let image = manager.getImage(imageName: pictureName, folderName: timeStamp) else {return nil}
        return image
    }
    
    func saveImage(imageCapture: UIImage?, timeStamp: String, PrePostFlag: Bool) {
        //guard let image = image else {return}
        var pictureName: String = timeStamp
        guard let image = imageCapture else {return}
        if PrePostFlag {
            pictureName = timeStamp + "-post"
            print("current time stamp is",timeStamp)
        }
        else {
            pictureName = timeStamp + "-pre"
            print("current time stamp is",timeStamp)
            //manager.addNewFolder(folderName: timeStamp)
        }
        infoMessage = manager.saveImage(image: image, imageName: pictureName)
        print(infoMessage)
    }
    
    func deleteImage() {
        infoMessage = manager.deleteImage(name: imageName)
    }
    
    func listSize() -> Int {
        DispatchQueue.main.async { [self] in
            self.folderCount = manager.printPath()
        }
        return folderCount
    }
    
    func getSortedList() -> [String]? {
        guard let dateList = manager.sortMainFolder() else {return nil}
        return dateList
    }
    
    func saveCSV(fileURL: URL, fileData: Data, completion: @escaping (Bool) -> Void) {
        //print("time stamp is: \(timeStamp)")
        manager.importCSV(fileURL: fileURL, data: fileData)
        completion(true)
    }
    
    func getDropBoxDataPackage(/*folderName: String,*/index: Int) -> (data: Data?, fileName: String?)? {
        guard let package = manager.fetchData(index: index) else {return (nil,nil)}
        return (package.data, package.fileName)
    }
    
    func getFolderName(index: Int) -> String? {
        guard let folderName = manager.getFolderName(index: index) else {return nil}
        return folderName
    }
    
    func getFolderSize(/*folderName: String*/) -> Int? {
        guard let folderSize = manager.getFolderSize() else {return nil}
        return folderSize
    }
    
    func getSurveyURL(surveyName: String) -> URL? {
        guard let surveyURL = manager.getPathForSurvey(surveyName: surveyName) else {return nil}
        return surveyURL
    }
    
    func deleteAllData() {
        manager.deleteMainFolder()
    }
    
    func getDataFilePath(fileName: String) -> URL? {
        guard let dataURL = manager.getPathForData(fileName: fileName) else {return nil}
        return dataURL
    }
    
    func getAllFilePaths() -> [URL]? {
        guard let URLs = manager.getMainDirectoryFilePaths() else {return nil}
        return URLs
    }
    
    func removeUploadedItem(fileURLToDelete: URL) {
        do {
            try manager.deleteFile(at: fileURLToDelete)
        } catch {
            print("Error deleting file: \(error)")
        }
    }

    
    
}
