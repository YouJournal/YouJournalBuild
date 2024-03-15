//
//  PasswordResetView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI

struct PasswordResetView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Assuming you have an image asset named "YJBackIcon"
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .padding(.leading, 20) // Move the back button to the left
                        .padding(.top, 20) // Adjust the top padding
                }
                Spacer() // Add a spacer to push the back button to the left
            }

            Text("Set New Password")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 24))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))

            SecureField("New Password", text: $newPassword)
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                .padding(.horizontal)
                .autocapitalization(.none)

            SecureField("Confirm Password", text: $confirmPassword)
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                .padding(.horizontal)
                .autocapitalization(.none)

            Button("Reset Password") {
                // Implement password reset logic here
            }
            .font(Font.custom("MontserratAlternates-SemiBold", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true) // Add this line if you want to hide the navigation bar
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}




