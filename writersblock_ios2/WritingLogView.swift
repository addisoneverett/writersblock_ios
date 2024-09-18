import SwiftUI

struct WritingLogView: View {
    @State private var searchText = ""
    @State private var sortOption = "Date"
    @State private var entries: [WritingEntry] = []
    @State private var selectedEntry: WritingEntry?
    @State private var showingEntryDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                TextField("Search entries...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                
                Picker("Sort", selection: $sortOption) {
                    Text("Date").tag("Date")
                    Text("Title").tag("Title")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
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
                LazyVStack(spacing: 10) {
                    ForEach(filteredAndSortedEntries) { entry in
                        EntryCardView(entry: entry, onDelete: { deleteEntry(entry) })
                            .onTapGesture {
                                selectedEntry = entry
                                showingEntryDetail = true
                            }
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: loadEntries)
        .sheet(isPresented: $showingEntryDetail) {
            if let entry = selectedEntry {
                EntryDetailView(entry: entry, onSave: updateEntry)
            }
        }
    }
    
    private var filteredAndSortedEntries: [WritingEntry] {
        let filtered = entries.filter { entry in
            searchText.isEmpty || entry.title.localizedCaseInsensitiveContains(searchText) || entry.text.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { (entry1, entry2) in
            if sortOption == "Date" {
                return entry1.date > entry2.date
            } else {
                return entry1.title < entry2.title
            }
        }
    }
    
    private func loadEntries() {
        if let savedEntries = UserDefaults.standard.data(forKey: "writingEntries") {
            let decoder = JSONDecoder()
            if let decodedEntries = try? decoder.decode([WritingEntry].self, from: savedEntries) {
                entries = decodedEntries
            }
        }
    }
    
    private func deleteEntry(_ entry: WritingEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    private func updateEntry(_ updatedEntry: WritingEntry) {
        if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
            var newEntry = updatedEntry
            newEntry.wordCount = updatedEntry.text.split(separator: " ").count
            entries[index] = newEntry
            saveEntries()
        }
    }
    
    private func saveEntries() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "writingEntries")
        }
    }
}

struct EntryCardView: View {
    let entry: WritingEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title.isEmpty ? "New Entry" : entry.title)
                    .font(.headline)
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(entry.text.prefix(50) + (entry.text.count > 50 ? "..." : ""))
                    .font(.body)
                    .lineLimit(2)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct EntryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var editedEntry: WritingEntry
    let onSave: (WritingEntry) -> Void
    
    init(entry: WritingEntry, onSave: @escaping (WritingEntry) -> Void) {
        _editedEntry = State(initialValue: entry)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $editedEntry.title)
                TextEditor(text: $editedEntry.text)
                    .frame(minHeight: 200)
            }
            .navigationTitle("Edit Entry")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(editedEntry)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct WritingLogView_Previews: PreviewProvider {
    static var previews: some View {
        WritingLogView()
    }
}