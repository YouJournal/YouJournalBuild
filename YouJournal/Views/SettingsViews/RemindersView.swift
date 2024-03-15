//
//  RemindersView.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct RemindersView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = false
    @State private var morningReminderEnabled = false
    @State private var eveningReminderEnabled = false
    @State private var morningReminderTime = Date()
    @State private var eveningReminderTime = Date()

    var body: some View {
        VStack {
            // Custom Header with Back Button and Title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Replace with your custom image if needed
                        .foregroundColor(.black)
                        .padding()
                }
                Spacer()
                Text("Reminders")
                    .font(.custom("MontserratAlternates-SemiBold", size: 22))
                    .padding()
                Spacer()
            }
            .padding(.bottom)

            Form {
                Section(header: Text("General").font(.custom("MontserratAlternates-Regular", size: 18))) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                }

                Section(header: Text("Specific Reminders").font(.custom("MontserratAlternates-Regular", size: 18))) {
                    Toggle(isOn: $morningReminderEnabled) {
                        Text("Morning Reminder")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                    .disabled(!notificationsEnabled) // Disable if notifications are off
                    
                    if morningReminderEnabled {
                        DatePicker("Time", selection: $morningReminderTime, displayedComponents: .hourAndMinute)
                            .disabled(!notificationsEnabled)
                    }
                    
                    Toggle(isOn: $eveningReminderEnabled) {
                        Text("Evening Reminder")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                    .disabled(!notificationsEnabled) // Disable if notifications are off
                    
                    if eveningReminderEnabled {
                        DatePicker("Time", selection: $eveningReminderTime, displayedComponents: .hourAndMinute)
                            .disabled(!notificationsEnabled)
                    }
                }
            }
            .onAppear {
                loadReminderSettings()
            }
            .onChange(of: morningReminderEnabled) { newValue in
                // Implement the logic to schedule/cancel the morning reminder
            }
            .onChange(of: eveningReminderEnabled) { newValue in
                // Implement the logic to schedule/cancel the evening reminder
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    private func loadReminderSettings() {
        // Load your reminder settings, potentially from UserDefaults
        // Example:
        // notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        // morningReminderEnabled = UserDefaults.standard.bool(forKey: "morningReminderEnabled")
        // eveningReminderEnabled = UserDefaults.standard.bool(forKey: "eveningReminderEnabled")
        // Here you would also load the times if they're saved
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RemindersView()
        }
    }
}

