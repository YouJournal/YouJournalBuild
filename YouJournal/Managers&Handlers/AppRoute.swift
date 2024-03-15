//
//  Approute.swift
//  YouJournal
//
//  Created by Luke Trotman on 20/3/2024.
//
enum AppRoute: Hashable {
    case getName
    case userPreferences
    case onboarding1
    case completeSignUp
    case signIn
    case journalHome
    // Journaling
    case recordJournal
    case playbackView
    case previousEntryView
    // Settings and Subviews
    case settingsView
    case remindersView
    case promptsView
    case userFeedbackView
    case securityView
    case preferenceSettingsView
    case tcView // Terms and Conditions View
}

