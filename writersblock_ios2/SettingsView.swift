import SwiftUI
import FamilyControls
import ManagedSettings
import Foundation

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("wordCountGoal") private var wordCountGoal = 500
    @AppStorage("resetTime") private var resetTime = "00:00"
    @State private var selectedTheme = "All Themes"
    @State private var resetDate = Date()
    @State private var isScreenTimeAuthorized = false
    @State private var tags: [Tag] = []  // Change this line
    @State private var newTag: String = ""
    @State private var showingTagManager = false
    @State private var tempWordCountGoal = 500
    @State private var tempResetDate = Date()
    @State private var hasUnsavedChanges = false

    var body: some View {
        Form {
            Section(header: Text("Writing Goals")) {
                HStack {
                    Text("Daily Word Goal:")
                    Spacer()
                    Text("\(formattedWordCountGoal)")
                    Stepper("", value: $tempWordCountGoal, in: 0...3000, step: stepValue)
                        .labelsHidden()
                        .scaleEffect(1.0)
                        .padding(.leading, 10)
                }
                .onChange(of: tempWordCountGoal) { _, _ in
                    hasUnsavedChanges = true
                }
                
                DatePicker("Daily Goal Reset Time", selection: $tempResetDate, displayedComponents: .hourAndMinute)
                    .onChange(of: tempResetDate) { _, _ in
                        hasUnsavedChanges = true
                    }
                
                Button("Save Changes") {
                    saveChanges()
                }
                .disabled(!hasUnsavedChanges)
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
                Button("Manage Tags") {
                    showingTagManager = true
                }
            }
            
            Section {
                NavigationLink("Manage Subscription", destination: Text("Subscription Management"))
                NavigationLink("Request a Feature", destination: Text("Feature Request"))
                NavigationLink("Contact Us", destination: Text("Contact Information"))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            initializeTempValues()
            checkScreenTimeAuthorization()
            loadTags()
        }
        .sheet(isPresented: $showingTagManager) {
            TagManagerView(tags: $tags)
        }
    }

    private var formattedWordCountGoal: String {
        return "\(tempWordCountGoal)"
    }

    private var stepValue: Int {
        return tempWordCountGoal < 100 ? 10 : 50
    }

    private func initializeTempValues() {
        tempWordCountGoal = wordCountGoal
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let date = formatter.date(from: resetTime) {
            tempResetDate = date
        }
    }

    private func saveChanges() {
        wordCountGoal = tempWordCountGoal
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        resetTime = formatter.string(from: tempResetDate)
        
        hasUnsavedChanges = false
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
    
    private func loadTags() {
        if let savedTags = UserDefaults.standard.data(forKey: "writingTags") {
            let decoder = JSONDecoder()
            if let decodedTags = try? decoder.decode([Tag].self, from: savedTags) {
                tags = decodedTags
            }
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

struct TagManagerView: View {
    @Binding var tags: [Tag]
    @State private var newTagName: String = ""
    @State private var newTagColor: Color = .blue
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add New Tag")) {
                    HStack {
                        TextField("New tag", text: $newTagName)
                        ColorPicker("", selection: $newTagColor)
                        Button("Add") {
                            if !newTagName.isEmpty && !tags.contains(where: { $0.name == newTagName }) {
                                tags.append(Tag(name: newTagName, color: newTagColor))
                                newTagName = ""
                                newTagColor = .blue
                                saveTags()
                            }
                        }
                    }
                }

                Section(header: Text("Existing Tags")) {
                    ForEach(tags) { tag in
                        HStack {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 20, height: 20)
                            Text(tag.name)
                        }
                    }
                    .onDelete(perform: deleteTags)
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func deleteTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
        saveTags()
    }

    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: "writingTags")
        }
    }
}