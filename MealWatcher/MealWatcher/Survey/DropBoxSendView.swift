//
//  DropBoxSendView.swift
//  SurveyDemoLight
//
//  Created by Jimmy Nguyen on 7/7/23.
//

import SwiftUI
import SwiftyDropbox

struct DropBoxSendView: View {
    @Environment(\.dismiss) var dismiss
    @State var client = DropboxClient(accessToken: "Fetch Token First")
    @State var accessToken: String = ""
    @State var testString: String = "Default Text"
    var data: Data
    
    var body: some View {
        VStack {
            HStack() {
                Button (action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .padding(20)
                })
                Spacer()
            }
            Spacer()
            /* Example for manual token */
            Button {
                //getAccessKey()
                let fileData = testString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                let request = client.files.upload(path: "/surveyTest/survey_test.json", mode: .overwrite ,input: data)
                    .response { response, error in
                        if let response = response {
                            print(response)
                        } else if let error = error {
                            print(error)
                        }
                    }
                    .progress { progressData in
                        print(progressData)
                    }
            } label: {
                Text("Test Send")
            }
            .padding()
            Button {
                refreshTokenRequest { accessToken in
                    if let accessToken = accessToken {
                        print("Access Token: \(accessToken)")
                        client = DropboxClient(accessToken: accessToken)
                        // Perform further actions with the access token
                    } else {
                        print("Failed to get access token")
                    }
                }
            } label: {
                Text("Get Access Code")
            }
            Spacer()
            
        }
        
    }
}

func refreshTokenRequest(completion: @escaping (String?) -> Void) {
    
    let refreshToken = "uJP2ag260-EAAAAAAAAAAcqokLsGCFLRUH8zpnCLs5B77vI2k7URVOCp23_EXP8K"
    let clientID = "e2jmr5ia4lmx4hd"
    let clientSecret = "ylzy537g124zuig"
    
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
