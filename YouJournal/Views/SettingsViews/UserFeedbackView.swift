//
//  UserFeedbackView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI

struct UserFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedbackText: String = ""
    @State private var showScreenshotAttachment: Bool = false // For future implementation

    var body: some View {
        VStack(alignment: .leading) {
            // Custom Header with Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Use your "YJBackIcon" if available
                        .foregroundColor(.black)
                        .imageScale(.large)
                        .padding()
                }

                Spacer()

                Text("User Feedback")
                    .font(.custom("MontserratAlternates-SemiBold", size: 22))
                    .padding()
            }

            Spacer(minLength: 20)
            
            Text("We'd love to hear from you!")
                .font(.custom("MontserratAlternates-SemiBold", size: 20))
                .padding([.leading, .trailing])

            TextEditor(text: $feedbackText)
                .font(.custom("MontserratAlternates-Regular", size: 18))
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .padding([.leading, .trailing])

            Button(action: {
                // Placeholder for photo/video upload logic
                showScreenshotAttachment.toggle()
            }) {
                Text("Attach Screenshot/Screen Recording")
                    .foregroundColor(.white)
                    .font(.custom("MontserratAlternates-Regular", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding([.leading, .trailing, .top])

            Button("Send Feedback") {
                // Logic for sending feedback to your server
            }
            .foregroundColor(.white)
            .font(.custom("MontserratAlternates-SemiBold", size: 18))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue) // Change to match your app's theme
            .cornerRadius(10)
            .padding([.leading, .trailing, .top])

            Spacer()

            Text("YouJournal made from London with Love.")
                .font(.custom("MontserratAlternates-Regular", size: 14))
                .padding()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct UserFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        UserFeedbackView()
    }
}

