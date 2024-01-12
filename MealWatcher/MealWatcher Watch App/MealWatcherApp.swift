//
//  WatchPhoneAppDemoApp.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 6/6/23.
//

import SwiftUI


@main
struct MealWatcherApp: App {
    @WKApplicationDelegateAdaptor private var extensionDelegate: ExtensionDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
               // .environment(\.appDelegate, delegate)
        }
    }
}

struct DelegateKey: EnvironmentKey {
    typealias Value = ExtensionDelegate?
    static let defaultValue: ExtensionDelegate? = nil
}

extension EnvironmentValues {
    var appDelegate: DelegateKey.Value {
        get {
            return self[DelegateKey.self]
        }
        set {
            self[DelegateKey.self] = newValue
        }
    }
}
