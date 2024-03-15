//
//  YouJournalApp.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import CloudKit
import AuthenticationServices

@main
struct YouJournalApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    init() {
        _ = AWSManager.shared // Initialize AWSManager
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if let userRecordData = UserDefaults.standard.data(forKey: "userRecord"),
                       let record = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [CKRecord.self], from: userRecordData) as? CKRecord,
                       UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
                        JournalHomeView(userRecord: record)
                    } else {
                        if authManager.isUserAuthenticated == nil {
                            LoadingView()
                        } else if authManager.isUserAuthenticated == false {
                            StartScreen()
                        } else {
                            StartScreen()
                        }
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(cloudKitManager)
            .onAppear {
                authManager.checkAuthenticationState()
                cloudKitManager.setupContainer { result in
                    switch result {
                    case .success:
                        print("CloudKit container set up successfully")
                    case .failure(let error):
                        print("Failed to set up CloudKit container: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
        }
    }
}
