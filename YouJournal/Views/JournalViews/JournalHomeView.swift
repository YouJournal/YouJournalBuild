//  JournalHome.swift
//  YouJournal
//  Created by Luke Trotman on 15/3/2024.

import SwiftUI
import CloudKit
import SDWebImageSwiftUI
import AWSS3

struct JournalEntry: Identifiable {
    let id: CKRecord.ID
    let date: Date
    var thumbnailURL: URL?
    var videoURL: URL?
}

struct JournalHomeView: View, Hashable {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @State private var searchText = ""
    @State private var navigateToSettings = false
    @State private var showRecordJournalView = false
    @State private var userName: String = ""
    @State private var userJournalEntries: [CKRecord] = []
    @State private var journalEntries: [JournalEntry] = []
    let userRecord: CKRecord
    
    init(userRecord: CKRecord) {
        self.userName = userRecord["name"] as? String ?? "Guest"
        self.userRecord = userRecord
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                // Top bar with username, settings icon
                HStack {
                    Spacer()
                    
                    Text("\(userName)'s YouJournal")
                        .font(.custom("MontserratAlternates-Regular", size: 24))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                
                // Custom search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Search YouJournal", text: $searchText)
                        .font(.custom("MontserratAlternates-Regular", size: 18))
                        .padding(15)
                        .background(Color(.systemGray6))
                        .cornerRadius(11)
                        .overlay(
                            HStack {
                                Spacer()
                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 10)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal)
                        .onSubmit {
                            // Action when search is submitted
                        }
                }
                
                // Calendar-like grid view
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 20) {
                        Button(action: {
                            showRecordJournalView = true
                        }) {
                            todayEntryView
                        }
                        
                        ForEach(journalEntries.filter({ !Calendar.current.isDate($0.date, inSameDayAs: Date()) })) { entry in
                            journalEntryView(for: entry)
                        }
                        
                        ForEach(missedDates, id: \.self) { date in
                            missedEntryView(date: date)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRecordJournalView) {
                RecordJournalView(onSave: {
                    fetchUserJournalEntries()
                })
            }
            .sheet(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
        .onAppear {
            fetchUserJournalEntries()
        }
    }
    
    private var todayEntryView: some View {
        ZStack {
            if let todayEntry = journalEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                NavigationLink(destination: PreviousEntryView(entry: todayEntry)) {
                    journalEntryView(for: todayEntry)
                }
            } else {
                VStack {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color.white)
                        .opacity(0.7)
                        .padding(.leading, 50)
                        .padding(.top, 110)
                }
                .frame(width: 120, height: 180)
                .background(Color("YJBlue"))
                .cornerRadius(11)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 0)
            }
        }
    }
    
    private var missedDates: [Date] {
        let startDate = userJournalEntries.first?.creationDate ?? Date()
        let endDate = Date()
        let daysRange = daysRange(from: startDate, to: endDate)
        
        return daysRange.filter { date in
            !journalEntries.contains { entry in
                Calendar.current.isDate(entry.date, inSameDayAs: date)
            }
        }
    }
    
    private func daysRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 0, to: currentDate)!
        }
        
        return dates
    }
    
    private func fetchUserJournalEntries() {
        let userID = userRecord.recordID
        cloudKitManager.fetchUserJournalEntries(userID: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.userJournalEntries = records
                    self.updateJournalEntries()
                case .failure(let error):
                    print("Failed to fetch user journal entries: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateJournalEntries() {
        let group = DispatchGroup()
        var updatedJournalEntries: [JournalEntry] = []

        userJournalEntries.forEach { record in
            if let date = record["date"] as? Date,
               let thumbnailURLString = record["thumbnailURL"] as? String,
               let thumbnailURL = URL(string: thumbnailURLString) {
                group.enter()

                let task = URLSession.shared.downloadTask(with: thumbnailURL) { localURL, response, error in
                    if let localURL = localURL {
                        let journalEntry = JournalEntry(id: record.recordID, date: date, thumbnailURL: localURL)
                        updatedJournalEntries.append(journalEntry)
                    } else {
                        print("Error downloading thumbnail: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    group.leave()
                }
                task.resume()
            }
        }

        group.notify(queue: .main) {
            // Sort the journal entries
            self.journalEntries = updatedJournalEntries.sorted { $0.date > $1.date }
        }
    }
    
    private func journalEntryView(for entry: JournalEntry) -> some View {
        NavigationLink(destination: PreviousEntryView(entry: entry)) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if let thumbnailURL = entry.thumbnailURL {
                        WebImage(url: thumbnailURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 180)
                            .cornerRadius(11)
                    } else {
                        Color.gray
                            .frame(width: 120, height: 180)
                            .cornerRadius(11)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(entry.date, format: .dateTime.weekday(.short))
                            .font(.custom("MontserratAlternates-Regular", size: 25))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                            .padding(.top, 10)
                            .padding(.leading, 10)

                        Text(entry.date, format: .dateTime.day())
                            .font(.custom("MontserratAlternates-Regular", size: 50))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                            .padding(.leading, 10)
                    }
                    .padding(.top, 10)
                    .background(Color.black.opacity(0.5))
                }
            }
            .frame(width: 120, height: 180)
            .background(Color.white)
            .cornerRadius(11)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 0)
        }
    }
    
    private func missedEntryView(date: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(date, format: .dateTime.weekday(.short))
                .font(.custom("MontserratAlternates-Regular", size: 25))
                .foregroundColor(.black)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding(.top, 10)
                .padding(.leading, 10)
            
            Text(date, format: .dateTime.day())
                .font(.custom("MontserratAlternates-Regular", size: 50))
                .foregroundColor(.black)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding(.leading, 10)
        }
        .frame(width: 120, height: 180)
        .background(Color.white)
        .cornerRadius(11)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 0)
    }
    
    // MARK: - Hashable conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userRecord.recordID)
    }
    
    static func == (lhs: JournalHomeView, rhs: JournalHomeView) -> Bool {
        return lhs.userRecord.recordID == rhs.userRecord.recordID
    }
}

struct JournalHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUserRecord = CKRecord(recordType: "Users", recordID: CKRecord.ID(recordName: "sampleUserID"))
        sampleUserRecord["name"] = "Sample User"
        return JournalHomeView(userRecord: sampleUserRecord)
    }
}
