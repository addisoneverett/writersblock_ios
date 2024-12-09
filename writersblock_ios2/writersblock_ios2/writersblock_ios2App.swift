//
//  writersblock_ios2App.swift
//  writersblock_ios2
//
//  Created by Addison Everett on 9/17/24.
//

import SwiftUI

@main
struct writersblock_ios2App: App {
    @StateObject private var writingStateManager = WritingStateManager()
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabBarView(selectedTab: $selectedTab) {
                Group {
                    if selectedTab == 0 {
                        ContentView()
                    } else if selectedTab == 1 {
                        WritingLogView()
                    } else if selectedTab == 2 {
                        AnalyticsView()
                    } else if selectedTab == 3 {
                        SettingsView()
                    }
                }
            }
            .environmentObject(writingStateManager)
        }
    }
}
