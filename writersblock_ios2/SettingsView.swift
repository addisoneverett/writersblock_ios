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
                        Text("Rule Configuration options will be here")
                        // Add rule configuration options in a new view
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}