import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("wordCountGoal") private var wordCountGoal = 500
    @AppStorage("resetTime") private var resetTime = "00:00"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Writing Goals")) {
                    Stepper("Daily Word Count Goal: \(wordCountGoal)", 
                            value: $wordCountGoal, 
                            in: 50...1000, 
                            step: 50)
                    DatePicker("Daily Goal Reset Time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                        .onChange(of: resetTime) { oldValue, newValue in
                            // Update reset time logic here
                            print("Reset time changed from \(oldValue) to \(newValue)")
                        }
                }
                
                Section {
                    NavigationLink("Rule Configuration") {
                        RuleConfigurationView()
                    }
                    
                    Button("Reset Daily Goal") {
                        wordCountGoal = 500 // Reset to default value
                    }
                }
                
                Section(header: Text("Writing Prompt Theme")) {
                    Picker("Theme", selection: .constant("All Themes")) {
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
        }
    }
}

struct RuleConfigurationView: View {
    @State private var blockedApps: Set<String> = []
    
    var body: some View {
        List {
            Section(header: Text("Select Apps to Block")) {
                ForEach(mockInstalledApps, id: \.bundleIdentifier) { app in
                    HStack {
                        Image(systemName: app.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text(app.name)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { blockedApps.contains(app.bundleIdentifier) },
                            set: { newValue in
                                if newValue {
                                    blockedApps.insert(app.bundleIdentifier)
                                } else {
                                    blockedApps.remove(app.bundleIdentifier)
                                }
                            }
                        ))
                    }
                }
            }
        }
        .navigationTitle("App Blocking")
    }
    
    private var mockInstalledApps: [AppInfo] = [
        AppInfo(name: "Facebook", bundleIdentifier: "com.facebook.Facebook", iconName: "f.circle.fill"),
        AppInfo(name: "Instagram", bundleIdentifier: "com.instagram.Instagram", iconName: "camera.circle.fill"),
        AppInfo(name: "Twitter", bundleIdentifier: "com.twitter.Twitter", iconName: "t.circle.fill"),
        AppInfo(name: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically", iconName: "music.note.circle.fill"),
        AppInfo(name: "YouTube", bundleIdentifier: "com.google.ios.youtube", iconName: "play.circle.fill"),
        AppInfo(name: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", iconName: "message.circle.fill"),
        AppInfo(name: "Snapchat", bundleIdentifier: "com.toyopagroup.picaboo", iconName: "camera.circle.fill"),
        AppInfo(name: "Reddit", bundleIdentifier: "com.reddit.Reddit", iconName: "r.circle.fill"),
        AppInfo(name: "LinkedIn", bundleIdentifier: "com.linkedin.LinkedIn", iconName: "l.circle.fill"),
        AppInfo(name: "Pinterest", bundleIdentifier: "pinterest", iconName: "p.circle.fill")
    ]
}

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let iconName: String
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}