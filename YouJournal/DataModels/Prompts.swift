//
//  Prompts.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//
import Foundation

struct Prompts: Identifiable {
    let id: String // Assuming `___recordID` as the unique identifier
    var interactedWith: Int64
    var promptID: String
    var promptText: String
    var responseVideo: String // Reference to a Video
    var userID: String // Reference to the User who interacted with this prompt
    
    init(id: String, interactedWith: Int64, promptID: String, promptText: String, responseVideo: String, userID: String) {
        self.id = id
        self.interactedWith = interactedWith
        self.promptID = promptID
        self.promptText = promptText
        self.responseVideo = responseVideo
        self.userID = userID
    }
}
