//
//  Analytics.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//


import Foundation

struct Analytics: Identifiable {
    let id: String // Assuming `___recordID` as the unique identifier
    var eventDetails: String
    var eventID: String
    var eventType: String
    var sessionID: String
    var userID: String // Reference to a User
    
    init(id: String, eventDetails: String, eventID: String, eventType: String, sessionID: String, userID: String) {
        self.id = id
        self.eventDetails = eventDetails
        self.eventID = eventID
        self.eventType = eventType
        self.sessionID = sessionID
        self.userID = userID
    }
}
