//
//  SettingsView.swift
//  WatchPhoneAppDemo
// 
//  This file contains the view for the settings tab. It allows the user to change the participant ID,
//  record which ring they are using, and allows syncing the app to a single ring. The user can
//  also delete all recorded data if needed.
//
//  Note: Bluetooth devices cannot be addressed by their MAC address on iOS devices. This is for security
//  purposes and is intentional by Apple. To get access to a specific Bluetooth device, the user must
//  connect to it first and the iOS device will create a UUID for it. Then, connections should be made by
//  looking for that specific UUID. These UUIDs are the MAC address but encypted. A single Bluetooth device 
//  (in this case a Genki ring) will have a different UUID on each device it is paired to unlike a MAC address 
//  which is specific to that ring.
//
//  Created by Jimmy Nguyen on 10/5/23.
//

import SwiftUI
import WatchConnectivity
var examplePID: String = "P9999"
var exampleRID: String = "00000000-1111-2222-3333-444455556666"

struct SettingsView: View {
    /* Binding variables are passed from the main view and are referenced in this view */
    @Binding var participantID: String
    @Binding var selectedOption: Int
    @Binding var ringUUIDString: String
    //@Binding var ringID: Int
    /* The state variables are local to this view */
    @State var watchID: String?
    @State var examplePID: String = "P9999"
    @State var exampleRID: String = "00000000-1111-2222-3333-444455556666"
    @State private var previousOption = 0
    let options = ["No Option Selected","1", "2", "3","4","5","6","7","8","9","10","11","12","13","14","15","16"]
    @State private var showAlert = false
    @State private var disableAlert = false
    @State private var deleteDataAlert = false
    @ObservedObject var vm = FileManagerViewModel()

    @ObservedObject private var bluetoothViewModel = BluetoothViewModel.instance
    
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .onAppear {
                    if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
                        self.watchID = deviceId
                    } else {
                        self.watchID = "Unable to retrieve device UUID"
                    }
                }
                .padding(.vertical)
            IDInputView(participantID: $participantID)
                .padding(.vertical)
            Text("Watch ID: \(watchID ?? "Unknown")")
                .padding(.vertical)
            HStack {
                Text("Select a Ring ID:")
                Picker("Select a Ring ID", selection: $selectedOption) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(options[index]).tag(index)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            Button("Pair Wave Ring") {
                bluetoothViewModel.allowNotifications = false
                guard let waveRing = bluetoothViewModel.waveRing else {return}
                bluetoothViewModel.connect(peripheral: waveRing)
                guard let ringUUID = bluetoothViewModel.getUUID(peripheral: waveRing) else {return}
                self.ringUUIDString = ringUUID.uuidString
            }
            Text("Ring UUID: \(ringUUIDString)")
                .padding(.bottom)
            Button(action: {
                deleteDataAlert.toggle()
            }, label: {
                Text("Delete All Data")
            })
            Spacer()
            
        }
        .padding()
        .onChange(of: selectedOption) { [oldValue = selectedOption] newValue in
            previousOption = oldValue
            selectedOption = newValue
            if disableAlert == false {
                showAlert = true
            }
            else {
                disableAlert = false
            }
        }
        .overlay(
            AlertView(isPresented: $showAlert, selectedOption: $selectedOption, previousOption: $previousOption, disableAlert: $disableAlert)
        )
        .alert(isPresented: $deleteDataAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you wish to discard all data?"),
                primaryButton: .default(Text("Yes")) {
                    vm.deleteAllData()
                },
                secondaryButton: .cancel()
            )
        }

    }


}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}

struct AlertView: View {
    @Binding var isPresented: Bool
    @Binding var selectedOption: Int
    @Binding var previousOption: Int
    @Binding var disableAlert: Bool
    

    var body: some View {
        if isPresented {
            ZStack {
                Color.gray.opacity(0.4).ignoresSafeArea()

                VStack {
                    Text("Confirmation")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.black)
                    
                    Text("You have unsaved changes. Do you want to discard them?")
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.black)
                    
                    HStack {
                        Button("Discard") {
                            selectedOption = previousOption
                            isPresented = false
                            disableAlert = true

                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Confirm") {
                            isPresented = false

                        }
                        .padding()
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding()
            }
            .transition(.opacity)
        }
    }
}



