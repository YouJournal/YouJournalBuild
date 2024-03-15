//
//  UserCKD.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//

import CloudKit

// Define the CKDataModel for the User record type
struct CKUser {
    static let recordType = "Users"
    
    struct Field {
        // Note: Removed id field as it's automatically managed by CloudKit
        static let email = "email"
        static let journalSettings = "journalSettings"
        static let lastSignIn = "lastSignIn"
        static let name = "name"
        static let preferences = "preferences"
        static let roles = "roles"
        static let videos = "videos"
    }
}

// Assume User is your app's user model
struct userCK {
    var email: String
    var journalSettings: String
    var lastSignIn: Date
    var name: String
    var preferences: [String] // Assuming preferences is an array of strings
    var roles: [Int] // Assuming roles are represented as integers
    var videos: [CKRecord.Reference] // Assuming videos are stored as references to video records
}

// Define a helper method to create a CKRecord from a User object
extension User {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKUser.recordType)
        
        // Removed setting of id as it's managed by CloudKit
        record[CKUser.Field.email] = email as String?
        record[CKUser.Field.journalSettings] = journalSettings as String?
        record[CKUser.Field.lastSignIn] = lastSignIn as Date?
        record[CKUser.Field.name] = name as String?
        record[CKUser.Field.preferences] = preferences as [String]?
        record[CKUser.Field.roles] = roles.map { $0.rawValue }
        
        return record
    }
}
