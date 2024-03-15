//
//  PreferenceSettingsView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI

struct PreferenceSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selections: [String] = []
    let options = ["Understand Yourself", "Ignite Your Motivation", "Healing & Resilience", "Just Explore"]

    var body: some View {
        VStack {
            // Back button and title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Replace with your custom image if needed
                        .foregroundColor(.black)
                }
                .padding()
                Spacer()
                Text("Preferences")
                    .font(Font.custom("MontserratAlternates-SemiBold", size: 22))
                Spacer()
            }
            
            Text("Select all that apply")
                .font(Font.custom("MontserratAlternates-Regular", size: 18))
                .padding()

            // Options as selectable buttons
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selections.contains(option) {
                        selections.removeAll { $0 == option }
                    } else {
                        selections.append(option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(Font.custom("MontserratAlternates-Regular", size: 18))
                            .foregroundColor(selections.contains(option) ? .white : .black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selections.contains(option) ? Color.black : Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .padding(4)
            }

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct PreferenceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSettingsView()
    }
}

