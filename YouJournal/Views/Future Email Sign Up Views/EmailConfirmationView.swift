//
//  EmailConfirmationView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI

struct EmailConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var confirmationCode: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Ensure this image is in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }
                Spacer()
            }
            .padding()

            Text("Email Confirmation")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 24))
                .padding(.bottom)

            TextField("Enter Confirmation Code", text: $confirmationCode)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(11)
                .font(Font.custom("MontserratAlternates-Regular", size: 18))
                .padding(.horizontal)
            
            Button(action: {
                // Add action to confirm confirmation code
                confirmConfirmationCode()
            }) {
                Text("Confirm")
                    .font(Font.custom("MontserratAlternates-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(11)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Text("Resend Code")
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .foregroundColor(.blue)
                .padding(.top, 10)
        }
        .padding()
        .navigationBarHidden(true)
    }

    func confirmConfirmationCode() {
        // Add code to confirm the confirmation code
    }
}

struct EmailConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailConfirmationView()
    }
}

