//
//  EditView.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 7/10/23.
//

import SwiftUI

struct EditView: View {
    /* Camera Variables */
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var timeStamp: String = ""
    @State var PrePostFlag: Bool = false
    
    
    var body: some View {
        
        VStack {
            Spacer()
            Button(action: {
                self.sourceType = .camera
                self.isImagePickerDisplay.toggle()
                HapticManager.instance.notification(type: .success)
            }, label: {
                StandardButton(title: "Add a pre-meal image")
            })
            Spacer()
            Button(action: {
                self.sourceType = .camera
                self.isImagePickerDisplay.toggle()
                HapticManager.instance.notification(type: .success)
            }, label: {
                StandardButton(title: "Add a post-meal image")
            })
            Spacer()
            Button(action: {
                
            }, label: {
                StandardButton(title: "Do the survey")
            })
            Spacer()
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            //ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType, PrePostFlag: $PrePostFlag)
        }
        
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}


