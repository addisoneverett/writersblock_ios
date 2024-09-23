import SwiftUI
import FamilyControls
import ManagedSettings

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("wordCountGoal") private var wordCountGoal = 500
    @AppStorage("resetTime") private var resetTime = "00:00"
    @State private var selectedTheme = "All Themes"
    @State private var resetDate = Date()
    @State private var isScreenTimeAuthorized = false
    
    var body: some View {
        Form {
            Section(header: Text("Writing Goals")) {
                Stepper("Daily Word Count Goal: \(wordCountGoal)", 
                        value: $wordCountGoal, 
                        in: 50...1000, 
                        step: 50)
                DatePicker("Daily Goal Reset Time", selection: $resetDate, displayedComponents: .hourAndMinute)
                    .onChange(of: resetDate) { oldValue, newValue in
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        resetTime = formatter.string(from: newValue)
                    }
            }
            
            Section {
                if isScreenTimeAuthorized {
                    NavigationLink("Rule Configuration") {
                        RuleConfigurationView()
                    }
                } else {
                    Button("Authorize ScreenTime") {
                        requestScreenTimeAuthorization()
                    }
                }
                
                Button("Reset Daily Goal") {
                    wordCountGoal = 500 // Reset to default value
                }
            }
            
            Section(header: Text("Writing Prompt Theme")) {
                Picker("Theme", selection: $selectedTheme) {
                    Text("All Themes").tag("All Themes")
                    Text("Creative Writing Prompts").tag("Creative Writing Prompts")
                    Text("Journaling Prompts").tag("Journaling Prompts")
                }
            }
            
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section {
                NavigationLink("Manage Subscription", destination: Text("Subscription Management"))
                NavigationLink("Request a Feature", destination: Text("Feature Request"))
                NavigationLink("Contact Us", destination: Text("Contact Information"))
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            checkScreenTimeAuthorization()
        }
    }
    
    private func checkScreenTimeAuthorization() {
        ScreenTimeAPI.shared.requestAuthorization { granted in
            isScreenTimeAuthorized = granted
        }
    }
    
    private func requestScreenTimeAuthorization() {
        ScreenTimeAPI.shared.requestAuthorization { granted in
            isScreenTimeAuthorized = granted
        }
    }
}

struct RuleConfigurationView: View {
    @State private var selection = FamilyActivitySelection()
    
    var body: some View {
        List {
            Section(header: Text("Select Apps to Block")) {
                FamilyActivityPicker(selection: $selection)
            }
        }
        .navigationTitle("App Blocking")
        .onChange(of: selection) { oldValue, newValue in
            updateBlockedApps(from: newValue)
        }
    }
    
    private func updateBlockedApps(from selection: FamilyActivitySelection) {
        ScreenTimeAPI.shared.blockApps(selection.applicationTokens, until: Date().addingTimeInterval(86400)) // Block for 24 hours
    }
}