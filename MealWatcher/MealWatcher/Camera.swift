//
//  Camera.swift
//  
//  This file is used to create the view used for the camera function. It requires the value of the pre/post flag used to designate the 
//  whether the image was taken before or after the meal was taken. It also requires the participantID. Both the flag and participant
//  ID is used for when the image is taken for the file name.
//
//  Created by Jimmy Nguyen on 6/8/23.
//

import UIKit
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {

    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var PrePostFlag: Bool
    @Binding var participantID: String
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }
   
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self, participantID: self.participantID)
    }
    
    
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    var participantID: String
    @ObservedObject var vm = FileManagerViewModel()
    
    init(picker: ImagePickerView, participantID: String) {
        self.picker = picker
        self.participantID = participantID
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        let timeStamp = participantID+"-"+df.string(from: date)
        
        vm.saveImage(imageCapture: selectedImage, timeStamp: timeStamp, PrePostFlag: self.picker.PrePostFlag)
        vm.image = selectedImage
        //toggleFlag(in: &self.picker)
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
    func toggleFlag(in ImagePickerView: inout ImagePickerView) {
        ImagePickerView.PrePostFlag.toggle()
        print("Toggled Flag!")
    }
    
}
