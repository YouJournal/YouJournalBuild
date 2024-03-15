//
//  PromptsView.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct PromptsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userInput: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Back button and title
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("YJBackIcon") // Ensure this is the correct image name
                            .foregroundColor(.black)
                            .padding()
                    }

                    Spacer()
                }

                Text("Customise Journal Prompts")
                    .font(Font.custom("MontserratAlternates-SemiBold", size: 22))
                    .padding()

                // Text Editor for user input
                ZStack(alignment: .topLeading) {
                    if userInput.isEmpty {
                        Text("Ex. 'What am I grateful for today?'")
                            .foregroundColor(Color.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $userInput)
                        .font(Font.custom("MontserratAlternates-Regular", size: 18))
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                }
                .frame(minHeight: 120)
                .padding()

                // Description before the bullet points
                Text("YouJournal's engine allows you to fine-tune your video journaling experience. You can add some short hints or tips for the model to prompt you more to your liking. For example:")
                    .font(Font.custom("MontserratAlternates-Regular", size: 18))
                    .padding([.top, .bottom])

                // Bullet points with examples
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(["\"Don't ask about past relationships.\"", "\"Speak to me as if I'm a Navy SEAL.\"", "\"Prompt me only about my marathon training.\""], id: \.self) { item in
                        Text("• \(item)")
                            .font(Font.custom("MontserratAlternates-Regular", size: 18))
                    }
                }
                .padding(.bottom)

                // Save Button
                Button(action: {
                    // Action to save the custom prompt
                    print("Custom prompt saved: \(userInput)")
                }) {
                    Text("Save")
                        .font(Font.custom("MontserratAlternates-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct PromptsView_Previews: PreviewProvider {
    static var previews: some View {
        PromptsView()
    }
}




