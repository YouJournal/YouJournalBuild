//
//  AnalyticsCKD.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//

import CloudKit

// Define the CKDataModel for the Analytics record type
struct CKAnalytics {
    static let recordType = "Analytics"
    
    struct Field {
        static let id = "___recordID"
        static let eventDetails = "eventDetails"
        static let eventID = "eventID"
        static let eventType = "eventType"
        static let sessionID = "sessionID"
        static let userID = "userID"
    }
}

// Define a helper method to create a CKRecord from an Analytics object
extension Analytics {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKAnalytics.recordType)
        record[CKAnalytics.Field.id] = id as CKRecordValue
        record[CKAnalytics.Field.eventDetails] = eventDetails as CKRecordValue
        record[CKAnalytics.Field.eventID] = eventID as CKRecordValue
        record[CKAnalytics.Field.eventType] = eventType as CKRecordValue
        record[CKAnalytics.Field.sessionID] = sessionID as CKRecordValue
        record[CKAnalytics.Field.userID] = userID as CKRecordValue
        return record
    }
}
