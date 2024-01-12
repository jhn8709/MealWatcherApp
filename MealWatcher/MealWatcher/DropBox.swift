//
//  DropBox.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 6/28/23.
//

import Foundation
import SwiftyDropbox
import SwiftUI


func refreshTokenRequest(completion: @escaping (String?) -> Void) {
    
    
    let refreshToken = "Paste Dropbox App refresh token here"
    let clientID = "Post Dropbox App client ID here"
    let clientSecret = "Paste Dropbox App client secret here"
    
    let url = URL(string: "https://api.dropbox.com/oauth2/token")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let parameters: [String: String] = [
        "refresh_token": refreshToken,
        "grant_type": "refresh_token",
        "client_id": clientID,
        "client_secret": clientSecret
    ]
    let postData = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    let postDataEncoded = postData.data(using: .utf8)
    
    request.httpBody = postDataEncoded
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }
        
        // Process the response data here
        // Example: Decode the JSON response
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            //print("Response JSON: \(json)")
            if let accessToken = json["access_token"] as? String {
                completion(accessToken)
                return
            }
        }
        completion(nil)
    }.resume()
}

func submitPayload(participantID: String, iOSFiles: FileManagerViewModel, completion: @escaping (DropboxClient?) -> Void) {
    refreshTokenRequest { accessToken in
        if let accessToken = accessToken {
            print("Access Token: \(accessToken)")
            let client = DropboxClient(accessToken: accessToken)
            // Perform further actions with the access token
            let dataCount = iOSFiles.listSize()
            //print("There are \(dataCount) files saved")
            guard let filePaths = iOSFiles.getAllFilePaths() else {return}
            
            var filesCommitInfo = [URL : Files.CommitInfo]()
            
            for filePath in filePaths {
                let fileUrl: URL! = filePath
                let uploadToPath = "/WATCH_SharedData/"+participantID+"/\(fileUrl.lastPathComponent)"
                filesCommitInfo[fileUrl] = Files.CommitInfo(path: uploadToPath, mode: Files.WriteMode.overwrite)
            }
            
            client.files.batchUploadFiles(
                fileUrlsToCommitInfo: filesCommitInfo,
                responseBlock: { (uploadResults: [URL: Files.UploadSessionFinishBatchResultEntry]?,
                                  finishBatchRequestError: CallError<Async.PollError>?,
                                  fileUrlsToRequestErrors: [URL: CallError<Async.PollError>]) -> Void in

                    if let uploadResults = uploadResults {
                        for (clientSideFileUrl, result) in uploadResults {
                            switch(result) {
                                case .success(let metadata):
                                    let dropboxFilePath = metadata.pathDisplay!
                                    print("Upload \(clientSideFileUrl.absoluteString) to \(dropboxFilePath) succeeded")
                                    iOSFiles.removeUploadedItem(fileURLToDelete: clientSideFileUrl)
                                case .failure(let error):
                                    print("Upload \(clientSideFileUrl.absoluteString) failed: \(error)")
                            }
                        }
                    }
                    else if let finishBatchRequestError = finishBatchRequestError {
                        print("Error uploading file: possible error on Dropbox server: \(finishBatchRequestError)")
                    } else if fileUrlsToRequestErrors.count > 0 {
                        print("Error uploading file: \(fileUrlsToRequestErrors)")
                    }
            })

            HapticManager.instance.notification(type: .success)
            completion(client)
        } else {
            HapticManager.instance.notification(type: .error)
            completion(nil)
            return
        }
    }
    
}

struct DropBoxView: View {
    
    @Binding var client: DropboxClient
    //var connectivityManager: WatchConnectivityManager
    var participantID: String
    var iOSFiles: FileManagerViewModel
    //var dataCount: Int
    @Binding var showAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    @State private var connection: Bool = false

    var body: some View {
        HStack () {
            Button {
                /* first check if the user has submitted a participant ID, else prompt them to*/
                if participantID.isEmpty {
                    print("Please enter your participant ID")
                    alertTitle = "Missing Participant ID"
                    alertMessage = "Please type in your participant ID before uploading any data."
                    showAlert.toggle()
                    HapticManager.instance.notification(type: .error)
                    return
                }
                else {
                    refreshTokenRequest { accessToken in
                        if let accessToken = accessToken {
                            print("Access Token: \(accessToken)")
                            client = DropboxClient(accessToken: accessToken)
                            // Perform further actions with the access token
                            let dataCount = iOSFiles.listSize()
                            print("There are \(dataCount) files saved")
                            guard let filePaths = iOSFiles.getAllFilePaths() else {return}
                            
                            var filesCommitInfo = [URL : Files.CommitInfo]()
                            
                            for filePath in filePaths {
                                let fileUrl: URL! = filePath
                                let uploadToPath = "/WATCH_SharedData/"+participantID+"/\(fileUrl.lastPathComponent)"
                                filesCommitInfo[fileUrl] = Files.CommitInfo(path: uploadToPath, mode: Files.WriteMode.overwrite)
                            }
                            
                            self.client.files.batchUploadFiles(
                                fileUrlsToCommitInfo: filesCommitInfo,
                                responseBlock: { (uploadResults: [URL: Files.UploadSessionFinishBatchResultEntry]?,
                                                  finishBatchRequestError: CallError<Async.PollError>?,
                                                  fileUrlsToRequestErrors: [URL: CallError<Async.PollError>]) -> Void in

                                    if let uploadResults = uploadResults {
                                        for (clientSideFileUrl, result) in uploadResults {
                                            switch(result) {
                                                case .success(let metadata):
                                                    let dropboxFilePath = metadata.pathDisplay!
                                                    print("Upload \(clientSideFileUrl.absoluteString) to \(dropboxFilePath) succeeded")
                                                    iOSFiles.removeUploadedItem(fileURLToDelete: clientSideFileUrl)
                                                case .failure(let error):
                                                    print("Upload \(clientSideFileUrl.absoluteString) failed: \(error)")
                                            }
                                        }
                                    }
                                    else if let finishBatchRequestError = finishBatchRequestError {
                                        print("Error uploading file: possible error on Dropbox server: \(finishBatchRequestError)")
                                    } else if fileUrlsToRequestErrors.count > 0 {
                                        print("Error uploading file: \(fileUrlsToRequestErrors)")
                                    }
                            })
                            
                            alertTitle = "Success!"
                            alertMessage = "The data is being uploaded currently. "
                            showAlert.toggle()
                            HapticManager.instance.notification(type: .success)
                        } else {
                            print("Failed to get access token")
                            alertTitle = "Connection to DropBox Failed"
                            alertMessage = "Cannot connect to DropBox. There may be an issue with your connection or the app."
                            HapticManager.instance.notification(type: .error)
                            return
                        }
                    }
                }
            } label: {
                Text("Send Data to DropBox")
            }
            .padding(.horizontal)
            
        }
    }
    func testDropBoxConnection(completion: @escaping (Bool) -> Void)
    {
        client.users.getCurrentAccount().response { response, error in
            if let _ = response {
                // Connection is successful
                print("Client connection is successful.")
                //let connection = true
                completion(true)
                // Proceed with uploading
            } else if let error = error {
                // Connection error occurred
                print("Error testing client connection: \(error)")
                completion(false)
                //let connection = false
            }
        }
    }
}
