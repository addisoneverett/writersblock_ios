//
//  ContentView.swift
//  writersblock_ios2
//
//  Created by Addison Everett on 9/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var content: String = ""
    @State private var title: String = ""
    @State private var showTitle: Bool = false
    @State private var wordCount: Int = 0
    @State private var wordCountGoal: Int = max(UserDefaults.standard.integer(forKey: "wordCountGoal"), 1)
    @State private var progress: Float = 0
    @State private var showSavedMessage: Bool = false
    @State private var activeView: Int = 0
    @State private var entries: [WritingEntry] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("\(wordCount) / \(wordCountGoal)")
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
                        if showTitle {
                            HStack {
                                TextField("Enter title...", text: $title)
                                    .font(.typewriter(size: 20))
                                    .fontWeight(.bold)
                                
                                Button(action: { showTitle = false }) {
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
                        
                        TextEditor(text: $content)
                            .font(.typewriterBody)
                            .padding()
                            .frame(minHeight: geometry.size.height - 200) // Adjust this value as needed
                            .onChange(of: content) { oldValue, newValue in
                                updateWordCount()
                            }
                    }
                }
                .frame(height: geometry.size.height - 110)
                
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
                        // Add action for ellipsis button here
                    }) {
                        Image(systemName: "ellipsis") // Changed from "text.quote" to "ellipsis"
                            .font(.title2)
                            .foregroundColor(.black)
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
            NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { _ in
                self.wordCountGoal = UserDefaults.standard.integer(forKey: "wordCountGoal")
                self.updateWordCount()
            }
        }
    }
    
    private func updateWordCount() {
        let words = content.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        wordCount = words.isEmpty ? 0 : words.count
        
        if wordCountGoal > 0 {
            progress = min(Float(wordCount) / Float(wordCountGoal), 1.0)
        } else {
            progress = 0
        }
    }
    
    private func saveEntry() {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let entry = WritingEntry(title: title.isEmpty ? "Untitled" : title, text: content, date: Date(), wordCount: wordCount)
        entries.append(entry)
        saveEntriesToUserDefaults()
        
        content = ""
        title = ""
        showTitle = false
        
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
}

struct WritingEntry: Codable, Identifiable {
    var id: UUID
    var title: String  // Changed from 'let' to 'var'
    var text: String   // Changed from 'let' to 'var'
    let date: Date
    var wordCount: Int // Changed from 'let' to 'var' to allow updates
    
    init(id: UUID = UUID(), title: String, text: String, date: Date, wordCount: Int) {
        self.id = id
        self.title = title
        self.text = text
        self.date = date
        self.wordCount = wordCount
    }
}
