import SwiftUI
import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct WritersBlockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var writingStateManager = WritingStateManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ContentView()
                        .navigationBarHidden(true)
                }
                .tabItem {
                    Image(systemName: "pencil")
                }

                NavigationView {
                    WritingLogView()
                        .navigationBarHidden(true)
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                }

                NavigationView {
                    AnalyticsView()
                        .navigationBarHidden(true)
                }
                .tabItem {
                    Image(systemName: "chart.bar")
                }

                NavigationView {
                    SettingsView()
                        .navigationBarHidden(true)
                }
                .tabItem {
                    Image(systemName: "gear")
                }
            }
            .environmentObject(writingStateManager)
        }
    }
}