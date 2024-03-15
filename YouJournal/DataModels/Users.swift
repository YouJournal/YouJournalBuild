//
//  Users.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//

import Foundation
import CloudKit

// Define the UserRole enum
enum UserRole: Int {
    case admin = 1
    case editor = 2
    case viewer = 3
    
    // Add additional roles as needed
    
    // This initializer is optional and helps in handling undefined roles
    init?(roleId: Int) {
        switch roleId {
        case 1: self = .admin
        case 2: self = .editor
        case 3: self = .viewer
        default: return nil
        }
    }
}

struct User: Identifiable {
    let id: String // Unique identifier, using `___recordID` from your schema
    var email: String // User's email for marketing
    var journalSettings: String // The text input a user inputs in settings to fine-tune Journal prompter
    var lastSignIn: Date // Date last signed in
    var name: String // The name the user would like to be called
    var preferences: [String] // List of preferences, assume string values for simplicity
    var roles: [UserRole] // Converted to use UserRole enum
    var videos: [CKRecord.Reference] // List of video IDs (references) the user has
    
    // Initialize your struct
    init(id: String, email: String, journalSettings: String, lastSignIn: Date, name: String, preferences: [String], roles: [Int], videos: [CKRecord.Reference]) {
        self.id = id
        self.email = email
        self.journalSettings = journalSettings
        self.lastSignIn = lastSignIn
        self.name = name
        self.preferences = preferences
        
        // Explicitly specify the initializer to use for UserRole conversion
        self.roles = roles.compactMap { UserRole(roleId: $0) }
        self.videos = videos
    }
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.email = record[CKUser.Field.email] as? String ?? ""
        self.journalSettings = record[CKUser.Field.journalSettings] as? String ?? ""
        self.lastSignIn = record[CKUser.Field.lastSignIn] as? Date ?? Date()
        self.name = record[CKUser.Field.name] as? String ?? ""
        self.preferences = record[CKUser.Field.preferences] as? [String] ?? []
        self.roles = (record[CKUser.Field.roles] as? [Int] ?? []).compactMap { UserRole(roleId: $0) }
        self.videos = record[CKUser.Field.videos] as? [CKRecord.Reference] ?? []
    }
}



