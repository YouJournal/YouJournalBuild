//
//  ForgotPasswordView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    
    var body: some View {
        VStack {
            // Back button at the top left
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Make sure this matches your asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(.black) // Adjust the color as needed
                }
                .padding()
                Spacer()
            }
            
            Spacer()
            
            // Forgot password image
            Image("ForgotPasswordImage") // Ensure this is the correct image asset
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            // Instructions
            Text("Forgot Password?")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 24))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .padding(.bottom, 8)
            
            Text("Enter your email address to request a password reset.")
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.50, green: 0.50, blue: 0.50))
                .padding(.horizontal)
            
            // Email input field
            TextField("Email", text: $email)
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            // Reset password button
            Button("Reset Password") {
                // Trigger password reset
            }
            .font(Font.custom("MontserratAlternates-SemiBold", size: 18))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black) // Adjust color to fit your app theme
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 16)
            
            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}


