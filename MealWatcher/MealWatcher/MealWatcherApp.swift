//
//  WatchPhoneAppDemoApp.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 6/6/23.
//

import SwiftUI
import SwiftyDropbox


@main
struct MealWatcherApp: App {
    @State private var lastRefresh = Date()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    
    init() {
        DropboxClientsManager.setupWithAppKey("Post Dropbox App client ID here")
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }


}
