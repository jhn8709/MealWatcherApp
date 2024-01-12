//
//  SurveyDemoLightApp.swift
//  SurveyDemoLight
//
//  Created by Jimmy Nguyen on 7/6/23.
//

import SwiftUI
import SwiftyDropbox

@main
struct SurveyDemoLightApp: App {
    
    init() {
        DropboxClientsManager.setupWithAppKey("e2jmr5ia4lmx4hd")
    }
    
    var body: some Scene {
        WindowGroup {
            SurveyView(survey: EMAQuestions)
        }
    }
}
