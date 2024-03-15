//
//  SettingsView.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userName: String = "Username" // Placeholder for dynamic user name retrieval

    var body: some View {
        VStack {
            // Custom Header with Back Button and Title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Ensure you have this asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.black)
                }
                .padding(.leading, 16)
                Spacer()
                Text("Settings")
                    .font(.custom("MontserratAlternates-SemiBold", size: 22))
                Spacer()
            }
            .padding(.vertical)
            .background(Color.white)

            // Settings List
            List {
                // Account Section
                Section(header: Text("Account")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(.black)) {
                    TextField("Change Name", text: $userName)
                        .font(.custom("MontserratAlternates-Regular", size: 18))
                }

                // General Section
                Section(header: Text("General")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(.black)) {
                    NavigationLink(destination: RemindersView()) {
                        Text("Reminders")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                    NavigationLink(destination: PreferenceSettingsView()) {
                        Text("Preferences")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                }

                // Prompt Fine Tuning Section
                Section(header: Text("Prompt Fine Tuning")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(.black)) {
                    NavigationLink(destination: PromptsView()) {
                        Text("Customize Prompts")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                }

                // Password & FaceID Section
                Section(header: Text("Password & FaceID")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(.black)) {
                    NavigationLink(destination: SecurityView()) {
                        Text("Password & FaceID")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                }

                // About Section
                Section(header: Text("About")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(.black)) {
                    NavigationLink(destination: TCView()) {
                        Text("Terms and Conditions")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


