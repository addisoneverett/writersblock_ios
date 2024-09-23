import SwiftUI

struct WritingLogView: View {
    @State private var entries: [WritingEntry] = []
    @State private var selectedEntryId: UUID?
    @State private var isEditViewPresented = false
    @State private var entryToDelete: WritingEntry?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                    EntryCard(entry: entry, onEdit: {
                        selectedEntryId = entry.id
                        isEditViewPresented = true
                    }, onDelete: {
                        entryToDelete = entry
                        showDeleteConfirmation = true
                    })
                }
            }
            .padding()
        }
        .navigationTitle("Writing Log")
        .onAppear(perform: loadEntries)
        .sheet(isPresented: $isEditViewPresented, onDismiss: saveEntries) {
            if let entryId = selectedEntryId,
               let entryIndex = entries.firstIndex(where: { $0.id == entryId }) {
                EditEntryView(entry: $entries[entryIndex])
            }
        }
        .confirmationDialog("Are you sure you want to delete this entry?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let entryToDelete = entryToDelete,
                   let index = entries.firstIndex(where: { $0.id == entryToDelete.id }) {
                    entries.remove(at: index)
                    saveEntries()
                }
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

    private func saveEntries() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "writingEntries")
        }
    }
}

struct EntryCard: View {
    let entry: WritingEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Text(entry.text)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(entry.wordCount) words")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture(perform: onEdit)
    }
}

struct EditEntryView: View {
    @Binding var entry: WritingEntry
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var text: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $text)
                }
                
                Section(header: Text("Statistics")) {
                    HStack {
                        Text("Word Count:")
                        Spacer()
                        Text("\(text.split(separator: " ").count)")
                    }
                    HStack {
                        Text("Date:")
                        Spacer()
                        Text(entry.date, style: .date)
                    }
                    HStack {
                        Text("Time:")
                        Spacer()
                        Text(entry.date, style: .time)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            title = entry.title
            text = entry.text
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.text = text
        entry.wordCount = text.split(separator: " ").count
    }
}
