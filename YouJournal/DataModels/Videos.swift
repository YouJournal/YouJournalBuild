//
//  Videos.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//

import Foundation

struct Video: Identifiable {
    let id: String // Assuming `___recordID` as the unique identifier
    var accessLevel: String
    var description: String
    var duration: Double
    var emotionsData: [String]
    var processed: String
    var tags: [String]
    var thumbnailImageURL: URL
    var title: String
    var transcription: String
    var userID: String // Reference to the User who owns this video
    var videoURL: URL
    
    init(id: String, accessLevel: String, description: String, duration: Double, emotionsData: [String], processed: String, tags: [String], thumbnailImageURL: URL, title: String, transcription: String, userID: String, videoURL: URL) {
        self.id = id
        self.accessLevel = accessLevel
        self.description = description
        self.duration = duration
        self.emotionsData = emotionsData
        self.processed = processed
        self.tags = tags
        self.thumbnailImageURL = thumbnailImageURL
        self.title = title
        self.transcription = transcription
        self.userID = userID
        self.videoURL = videoURL
    }
}
