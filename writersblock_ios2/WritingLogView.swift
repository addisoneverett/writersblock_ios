import SwiftUI
import Foundation

struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    var entries: [WritingEntry]

    init(id: UUID = UUID(), name: String, entries: [WritingEntry] = []) {
        self.id = id
        self.name = name
        self.entries = entries
    }
    
    var totalEntries: Int {
        entries.count
    }
    
    var totalWords: Int {
        entries.reduce(0) { $0 + $1.wordCount }
    }
}

struct WritingLogView: View {
    @State private var folders: [Folder] = []
    @State private var selectedFolderId: UUID?
    @State private var selectedEntryId: UUID?
    @State private var isEditViewPresented = false
    @State private var entryToDelete: WritingEntry?
    @State private var showDeleteConfirmation = false
    @State private var showingFolderCreation = false
    @State private var newFolderName = ""
    @State private var currentIndex: Int = 0
    
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    @State private var selectedTags: Set<UUID> = []
    @State private var selectedFolders: Set<UUID> = []
    @State private var selectedDateRange: DateRange = .allTime
    @State private var availableMonths: [Date] = []
    
    var menuItems: [String] {
        ["Folders", "All Entries"] + folders.filter { $0.name != "All Entries" }.map { $0.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText)
                Button(action: { showingFilterOptions = true }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
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
            
            // Horizontal scrollable menu
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(menuItems.enumerated()), id: \.element) { index, item in
                            Text(item)
                                .font(.system(size: 16))
                                .foregroundColor(currentIndex == index ? .blue : .primary)
                                .id(index)
                                .onTapGesture {
                                    withAnimation {
                                        currentIndex = index
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .onChange(of: currentIndex) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.2)),
                alignment: .bottom
            )

            // Content based on selection
            if currentIndex == 0 {
                foldersView
            } else if currentIndex == 1 {
                allEntriesView
            } else {
                folderView(folders[currentIndex - 2])
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadFoldersAndEntries)
        .sheet(isPresented: $showingFilterOptions) {
            FilterView(selectedTags: $selectedTags,
                       selectedFolders: $selectedFolders,
                       selectedDateRange: $selectedDateRange,
                       availableTags: getAllTags(),
                       availableFolders: folders,
                       availableMonths: availableMonths)
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width < -50 && currentIndex < menuItems.count - 1 {
                        withAnimation {
                            currentIndex += 1
                        }
                    } else if gesture.translation.width > 50 && currentIndex > 0 {
                        withAnimation {
                            currentIndex -= 1
                        }
                    }
                }
        )
        .sheet(isPresented: $isEditViewPresented, onDismiss: saveFolders) {
            if let folderId = selectedFolderId,
               let entryId = selectedEntryId,
               let folderIndex = folders.firstIndex(where: { $0.id == folderId }),
               let entryIndex = folders[folderIndex].entries.firstIndex(where: { $0.id == entryId }) {
                EditEntryView(entry: $folders[folderIndex].entries[entryIndex], folders: folders, currentFolderId: folderId)
            }
        }
        .confirmationDialog("Are you sure you want to delete this entry?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let entryToDelete = entryToDelete,
                   let folderIndex = folders.firstIndex(where: { $0.entries.contains(where: { $0.id == entryToDelete.id }) }),
                   let entryIndex = folders[folderIndex].entries.firstIndex(where: { $0.id == entryToDelete.id }) {
                    folders[folderIndex].entries.remove(at: entryIndex)
                    saveFolders()
                }
            }
        }
        .alert("Create New Folder", isPresented: $showingFolderCreation) {
            TextField("Folder Name", text: $newFolderName)
            Button("Create") {
                if !newFolderName.isEmpty {
                    folders.append(Folder(name: newFolderName))
                    newFolderName = ""
                    saveFolders()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var foldersView: some View {
        VStack {
            List {
                ForEach(folders.filter { $0.name != "All Entries" }) { folder in
                    NavigationLink(destination: folderView(folder)) {
                        FolderRowView(folder: folder)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                showingFolderCreation = true
            }) {
                Text("Create New Folder")
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }

    private var allEntriesView: some View {
        List {
            ForEach(filteredEntries, id: \.id) { entry in
                EntryCard(entry: entry, onEdit: {
                    selectedFolderId = folders.first { $0.entries.contains(where: { $0.id == entry.id }) }?.id
                    selectedEntryId = entry.id
                    isEditViewPresented = true
                }, onDelete: {
                    entryToDelete = entry
                    showDeleteConfirmation = true
                })
            }
        }
        .listStyle(PlainListStyle())
    }

    private func folderView(_ folder: Folder) -> some View {
        VStack(spacing: 0) {
            FolderStatsView(folder: folder)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            List {
                ForEach(folder.entries.sorted(by: { $0.date > $1.date })) { entry in
                    EntryCard(entry: entry, onEdit: {
                        selectedFolderId = folder.id
                        selectedEntryId = entry.id
                        isEditViewPresented = true
                    }, onDelete: {
                        entryToDelete = entry
                        showDeleteConfirmation = true
                    })
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(folder.name)
    }

    private var filteredEntries: [WritingEntry] {
        let allEntries = folders.flatMap { $0.entries }
        return allEntries.filter { entry in
            let matchesSearch = searchText.isEmpty || entry.title.localizedCaseInsensitiveContains(searchText) || entry.text.localizedCaseInsensitiveContains(searchText)
            let matchesTags = selectedTags.isEmpty || Set(entry.tags.map { $0.id }).intersection(selectedTags).count > 0
            let matchesFolders = selectedFolders.isEmpty || selectedFolders.contains(folders.first { $0.entries.contains(where: { $0.id == entry.id }) }?.id ?? UUID())
            let matchesDateRange = selectedDateRange.contains(entry.date)
            return matchesSearch && matchesTags && matchesFolders && matchesDateRange
        }.sorted(by: { $0.date > $1.date })
    }

    private func getAllTags() -> [Tag] {
        Array(Set(folders.flatMap { $0.entries.flatMap { $0.tags } }))
    }

    private func loadFoldersAndEntries() {
        if let savedFolders = UserDefaults.standard.data(forKey: "writingFolders") {
            let decoder = JSONDecoder()
            if let decodedFolders = try? decoder.decode([Folder].self, from: savedFolders) {
                folders = decodedFolders
            }
        } else if let savedEntries = UserDefaults.standard.data(forKey: "writingEntries") {
            let decoder = JSONDecoder()
            if let decodedEntries = try? decoder.decode([WritingEntry].self, from: savedEntries) {
                folders = [Folder(name: "All Entries", entries: decodedEntries)]
            }
        }
        
        if folders.isEmpty {
            folders = [Folder(name: "All Entries")]
        }
        
        // Ensure there's only one "All Entries" folder
        if folders.filter({ $0.name == "All Entries" }).count > 1 {
            let allEntries = folders.flatMap { $0.entries }
            folders = folders.filter { $0.name != "All Entries" }
            folders.insert(Folder(name: "All Entries", entries: allEntries), at: 0)
        }
        
        // Calculate available months
        let allDates = folders.flatMap { $0.entries }.map { $0.date }
        availableMonths = Array(Set(allDates.map { $0.startOfMonth })).sorted().reversed()
    }

    private func saveFolders() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(folders) {
            UserDefaults.standard.set(encoded, forKey: "writingFolders")
        }
    }
}

struct FolderRowView: View {
    let folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(folder.name)
                .font(.headline)
            Text("\(folder.totalEntries) entries • \(folder.totalWords) words")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct FolderStatsView: View {
    let folder: Folder
    
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 4) {
                Text("\(folder.totalEntries)")
                    .font(.headline)
                Text("entries")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 4) {
                Text("\(folder.totalWords)")
                    .font(.headline)
                Text("words")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
            
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag.color.opacity(0.2))
                                .foregroundColor(tag.color)
                                .cornerRadius(4)
                        }
                    }
                }
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
    let folders: [Folder]
    @State private var currentFolderId: UUID
    @State private var selectedFolderId: UUID
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var text: String = ""
    @State private var tags: [Tag] = []
    @State private var showTagSelection = false
    @State private var availableTags: [Tag] = []

    init(entry: Binding<WritingEntry>, folders: [Folder], currentFolderId: UUID) {
        self._entry = entry
        self.folders = folders
        self._currentFolderId = State(initialValue: currentFolderId)
        self._selectedFolderId = State(initialValue: currentFolderId)
    }

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
                
                Section(header: Text("Tags")) {
                    Button("Edit Tags") {
                        loadAvailableTags()
                        showTagSelection = true
                    }
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags) { tag in
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(tag.color.opacity(0.2))
                                        .foregroundColor(tag.color)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Folder")) {
                    Picker("Folder", selection: $selectedFolderId) {
                        ForEach(folders) { folder in
                            Text(folder.name).tag(folder.id)
                        }
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
        .sheet(isPresented: $showTagSelection) {
            TagSelectionView(availableTags: $availableTags, selectedTags: $tags)
        }
        .onAppear {
            title = entry.title
            text = entry.text
            tags = entry.tags
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.text = text
        entry.wordCount = text.split(separator: " ").count
        entry.tags = tags

        // Note: We can't modify folders here as it's a let constant.
        // The folder change should be handled in the parent view after dismissal.
    }

    private func loadAvailableTags() {
        if let savedTags = UserDefaults.standard.data(forKey: "writingTags") {
            let decoder = JSONDecoder()
            if let decodedTags = try? decoder.decode([Tag].self, from: savedTags) {
                availableTags = decodedTags
            }
        }
    }
}

struct FilterView: View {
    @Binding var selectedTags: Set<UUID>
    @Binding var selectedFolders: Set<UUID>
    @Binding var selectedDateRange: DateRange
    let availableTags: [Tag]
    let availableFolders: [Folder]
    let availableMonths: [Date]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tags")) {
                    ForEach(availableTags) { tag in
                        MultipleSelectionRow(title: tag.name, color: tag.color, isSelected: selectedTags.contains(tag.id)) {
                            if selectedTags.contains(tag.id) {
                                selectedTags.remove(tag.id)
                            } else {
                                selectedTags.insert(tag.id)
                            }
                        }
                    }
                }

                Section(header: Text("Folders")) {
                    ForEach(availableFolders) { folder in
                        MultipleSelectionRow(title: folder.name, color: .clear, isSelected: selectedFolders.contains(folder.id)) {
                            if selectedFolders.contains(folder.id) {
                                selectedFolders.remove(folder.id)
                            } else {
                                selectedFolders.insert(folder.id)
                            }
                        }
                    }
                }

                Section(header: Text("Date Range")) {
                    Picker("Date Range", selection: $selectedDateRange) {
                        Text("All Time").tag(DateRange.allTime)
                        Text("Last Month").tag(DateRange.lastMonth)
                        Text("Last Year").tag(DateRange.lastYear)
                        ForEach(availableMonths, id: \.self) { date in
                            Text(monthYearString(from: date)).tag(DateRange.custom(date, date.endOfMonth))
                        }
                    }
                }

                Section {
                    Button("Reset Filters") {
                        resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func resetFilters() {
        selectedTags.removeAll()
        selectedFolders.removeAll()
        selectedDateRange = .allTime
    }
}
