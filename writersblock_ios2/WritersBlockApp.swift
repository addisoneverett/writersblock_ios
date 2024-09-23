import SwiftUI
import Firebase
import UIKit

@main
struct WritersBlockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var writingStateManager = WritingStateManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ContentView()
                }
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Write")
                }

                NavigationView {
                    WritingLogView()
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Log")
                }

                NavigationView {
                    AnalyticsView()
                }
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analytics")
                }

                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
            .environmentObject(writingStateManager)
        }
    }
}