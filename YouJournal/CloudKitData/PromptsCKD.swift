//
//  PromptsCKD.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//

import CloudKit

// Define the CKDataModel for the Prompts record type
struct CKPrompts {
    static let recordType = "Prompts"
    
    struct Field {
        static let id = "___recordID"
        static let interactedWith = "interactedWith"
        static let promptID = "promptID"
        static let promptText = "promptText"
        static let responseVideo = "responseVideo"
        static let userID = "userID"
    }
}

// Define a helper method to create a CKRecord from a Prompts object
extension Prompts {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKPrompts.recordType)
        record[CKPrompts.Field.id] = id as CKRecordValue
        record[CKPrompts.Field.interactedWith] = interactedWith as CKRecordValue
        record[CKPrompts.Field.promptID] = promptID as CKRecordValue
        record[CKPrompts.Field.promptText] = promptText as CKRecordValue
        record[CKPrompts.Field.responseVideo] = responseVideo as CKRecordValue
        record[CKPrompts.Field.userID] = userID as CKRecordValue
        return record
    }
}
