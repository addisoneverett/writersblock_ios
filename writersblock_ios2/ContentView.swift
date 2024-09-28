//
//  ContentView.swift
//  writersblock_ios2
//
//  Created by Addison Everett on 9/17/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var writingStateManager: WritingStateManager
    @AppStorage("wordCountGoal") private var wordCountGoal: Int = 500
    @State private var progress: Float = 0
    @State private var showSavedMessage: Bool = false
    @State private var entries: [WritingEntry] = []
    @State private var showAccordionMenu: Bool = false
    @State private var showingPrompt = false
    @State private var generatedPrompt = ""
    @State private var showPrompt = false
    @State private var showTagSelection = false
    @State private var selectedTags: [Tag] = []
    @State private var availableTags: [Tag] = []
    @State private var showFolderSelection = false
    @State private var folders: [Folder] = []
    @State private var selectedFolderId: UUID?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("\(writingStateManager.currentWordCount) / \(wordCountGoal)")
                        .font(.typewriter(size: 14))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    ProgressView(value: progress)
                        .frame(width: 96, height: 12)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.black))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary.opacity(0.2)),
                    alignment: .bottom
                )
                
                // Main content
                ScrollView {
                    VStack(spacing: 0) {
                        if writingStateManager.showTitle {
                            HStack {
                                TextField("Enter title...", text: $writingStateManager.title)
                                    .font(.typewriter(size: 20))
                                    .fontWeight(.bold)
                                    
                                Button(action: { writingStateManager.showTitle = false }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.2)),
                                alignment: .bottom
                            )
                        }
                        
                        // Display selected tags
                        if !selectedTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(selectedTags) { tag in
                                        Text(tag.name)
                                            .font(.typewriter(size: 6))  // Changed from 12 to 6
                                            .padding(.horizontal, 4)     // Reduced padding
                                            .padding(.vertical, 2)       // Reduced padding
                                            .background(tag.color.opacity(0.1))
                                            .cornerRadius(2)             // Reduced corner radius
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)  // Reduced vertical padding
                            .background(Color(.systemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.2)),
                                alignment: .bottom
                            )
                        }
                        
                        // Folder location preview
                        if let selectedFolderId = selectedFolderId,
                           let folderName = folders.first(where: { $0.id == selectedFolderId })?.name {
                            Text(folderName)
                                .font(.typewriter(size: 6))  // Changed from 8 to 6
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                                .padding(.horizontal)
                        }
                        
                        RichTextEditor(text: Binding(
                            get: { self.writingStateManager.content },
                            set: { self.writingStateManager.content = $0 }
                        ), font: .systemFont(ofSize: 16))
                            .frame(minHeight: geometry.size.height - 200)
                            .onChange(of: writingStateManager.content) { oldValue, newValue in
                                updateWordCount()
                            }
                    }
                }
                .frame(height: geometry.size.height - 200)

                Spacer()

                // Writing Prompt Box (if shown)
                if showPrompt {
                    HStack {
                        Text(generatedPrompt)
                            .font(.typewriter(size: 12))
                            .italic()
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button(action: {
                            showPrompt = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                                .font(.typewriter(size: 10))
                        }
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Save button and options
                HStack {
                    Button("Save") {
                        saveEntry()
                    }
                    .font(.typewriter(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showAccordionMenu.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(90))
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary.opacity(0.2)),
                    alignment: .top
                )
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        if showAccordionMenu {
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                    }
            )
            
            // Accordion Menu
            VStack {
                Spacer()
                if showAccordionMenu {
                    VStack(alignment: .trailing, spacing: 20) {
                        Button("Add a title") {
                            writingStateManager.showTitle = true
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                        Button("Add tags") {
                            loadAvailableTags()
                            showTagSelection = true
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                        Button("Add to Folder") {
                            showFolderSelection = true
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                        Button("Scan a document") {
                            // Implement document scanning
                            print("Scan a document")
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                        Button("Generate Writing Prompt") {
                            generatedPrompt = generateWritingPrompt()
                            showPrompt = true
                            withAnimation(.spring()) {
                                showAccordionMenu = false
                            }
                        }
                    }
                    .font(.typewriter(size: 16))
                    .foregroundColor(.black)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.vertical, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 80)
        }
        .background(Color(.systemBackground))
        .overlay(
            Group {
                if showSavedMessage {
                    Text("Saved!")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        )
        .onAppear {
            loadEntries()
            loadFolders()
            updateWordCount()
        }
        .sheet(isPresented: $showTagSelection) {
            TagSelectionView(availableTags: $availableTags, selectedTags: $selectedTags)
        }
        .sheet(isPresented: $showFolderSelection) {
            FolderSelectionView(folders: $folders, selectedFolderId: $selectedFolderId)
        }
    }
    
    private func updateWordCount() {
        writingStateManager.updateWordCount()
        if wordCountGoal > 0 {
            progress = min(Float(writingStateManager.currentWordCount) / Float(wordCountGoal), 1.0)
        } else {
            progress = 0
        }
    }
    
    private func saveEntry() {
        guard !writingStateManager.content.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let entry = WritingEntry(title: writingStateManager.title.isEmpty ? "New Entry" : writingStateManager.title,
                                 text: writingStateManager.content.string,
                                 date: Date(),
                                 wordCount: writingStateManager.currentWordCount,
                                 tags: selectedTags)
        
        if let selectedFolderId = selectedFolderId,
           let folderIndex = folders.firstIndex(where: { $0.id == selectedFolderId }) {
            folders[folderIndex].entries.append(entry)
        } else {
            // If no folder is selected, add to "All Entries"
            if let allEntriesIndex = folders.firstIndex(where: { $0.name == "All Entries" }) {
                folders[allEntriesIndex].entries.append(entry)
            } else {
                folders.append(Folder(name: "All Entries", entries: [entry]))
            }
        }
        
        saveFolders()
        
        writingStateManager.clearContent()
        selectedTags.removeAll()
        selectedFolderId = nil
        
        withAnimation {
            showSavedMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSavedMessage = false
            }
        }
        
        updateWordCount()
    }
    
    private func loadEntries() {
        if let savedEntries = UserDefaults.standard.data(forKey: "writingEntries") {
            let decoder = JSONDecoder()
            if let decodedEntries = try? decoder.decode([WritingEntry].self, from: savedEntries) {
                entries = decodedEntries
            }
        }
    }
    
    private func saveEntriesToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "writingEntries")
        }
    }
    
    private func generateWritingPrompt() -> String {
        let prompts = [
            "Write about a character who discovers a hidden door in their house.",
            "Describe a world where everyone has a superpower, except for one person.",
            "Tell a story that takes place entirely in an elevator.",
            "Write about a day in the life of a sentient cloud.",
            "Describe a future where books are forbidden.",
            "Write about a character who wakes up one day speaking a language they don't know.",
            "Tell a story about the last person on Earth.",
            "Describe an encounter with a mythical creature in a modern city.",
            "Write about a character who can taste colors.",
            "Tell a story that begins and ends with the same sentence."
        ]
        return prompts.randomElement() ?? "Write about your perfect day."
    }

    private func loadAvailableTags() {
        if let savedTags = UserDefaults.standard.data(forKey: "writingTags") {
            let decoder = JSONDecoder()
            if let decodedTags = try? decoder.decode([Tag].self, from: savedTags) {
                availableTags = decodedTags
            }
        }
    }

    private func loadFolders() {
        if let savedFolders = UserDefaults.standard.data(forKey: "writingFolders") {
            let decoder = JSONDecoder()
            if let decodedFolders = try? decoder.decode([Folder].self, from: savedFolders) {
                folders = decodedFolders
            }
        }
        
        if folders.isEmpty {
            folders = [Folder(name: "All Entries")]
        }
    }

    private func saveFolders() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(folders) {
            UserDefaults.standard.set(encoded, forKey: "writingFolders")
        }
    }
}

struct WritingEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var text: String
    let date: Date
    var wordCount: Int
    var tags: [Tag]
    var notes: String
    
    init(id: UUID = UUID(), title: String, text: String, date: Date, wordCount: Int, tags: [Tag] = [], notes: String = "") {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
        self.wordCount = wordCount
        self.tags = tags
        self.notes = notes
    }
}

struct Tag: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: Color
    
    enum CodingKeys: String, CodingKey {
        case id, name, color
    }
    
    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let colorData = try container.decode(Data.self, forKey: .color)
        color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)?.color ?? .blue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}

extension UIColor {
    var color: Color {
        Color(self)
    }
}

struct TagSelectionView: View {
    @Binding var availableTags: [Tag]
    @Binding var selectedTags: [Tag]
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
                            if !newTagName.isEmpty && !availableTags.contains(where: { $0.name == newTagName }) {
                                let newTag = Tag(name: newTagName, color: newTagColor)
                                availableTags.append(newTag)
                                selectedTags.append(newTag)
                                newTagName = ""
                                newTagColor = .blue
                                saveTags()
                            }
                        }
                    }
                }

                Section(header: Text("Select Tags")) {
                    ForEach(availableTags) { tag in
                        MultipleSelectionRow(title: tag.name, color: tag.color, isSelected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.removeAll { $0.id == tag.id }
                            } else {
                                selectedTags.append(tag)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(availableTags) {
            UserDefaults.standard.set(encoded, forKey: "writingTags")
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var color: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct FolderSelectionView: View {
    @Binding var folders: [Folder]
    @Binding var selectedFolderId: UUID?
    @State private var newFolderName = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(folders) { folder in
                    Button(action: {
                        selectedFolderId = folder.id
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(folder.name)
                    }
                }
                
                Section(header: Text("Create New Folder")) {
                    HStack {
                        TextField("New Folder Name", text: $newFolderName)
                        Button("Create") {
                            if !newFolderName.isEmpty {
                                let newFolder = Folder(name: newFolderName)
                                folders.append(newFolder)
                                newFolderName = ""
                                saveFolders()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Folder")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveFolders() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(folders) {
            UserDefaults.standard.set(encoded, forKey: "writingFolders")
        }
    }
}
