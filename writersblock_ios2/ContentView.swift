//
//  ContentView.swift
//  writersblock_ios2
//
//  Created by Addison Everett on 9/17/24.
//

import SwiftUI

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
                        Button("Generate Writing Prompt") {
                            generatedPrompt = generateWritingPrompt()
                            showPrompt = true
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
            updateWordCount()
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
        
        let entry = WritingEntry(title: writingStateManager.title.isEmpty ? "New Entry" : writingStateManager.title, text: writingStateManager.content.string, date: Date(), wordCount: writingStateManager.currentWordCount)
        entries.append(entry)
        saveEntriesToUserDefaults()
        
        writingStateManager.clearContent()
        
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
}

struct WritingEntry: Codable, Identifiable {
    var id: UUID
    var title: String
    var text: String
    let date: Date
    var wordCount: Int
    
    init(id: UUID = UUID(), title: String, text: String, date: Date, wordCount: Int) {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
        self.wordCount = wordCount
    }
}
