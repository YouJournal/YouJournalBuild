//
//  SecurityView.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import LocalAuthentication

struct SecurityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isFaceIDEnabled = false
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var showForgotPassword = false

    var body: some View {
        VStack {
            // Back button and title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Replace with your custom image if needed
                        .foregroundColor(.black)
                        .padding()
                }
                Spacer()
                Text("Security")
                    .font(Font.custom("MontserratAlternates-SemiBold", size: 22))
                Spacer()
            }
            .padding(.bottom, 20)

            // Face ID Toggle
            Toggle(isOn: $isFaceIDEnabled) {
                Text("Enable Face ID")
                    .font(Font.custom("MontserratAlternates-Regular", size: 18))
            }
            .padding()
            .onChange(of: isFaceIDEnabled) { _ in
                authenticateWithFaceID()
            }

            // Password Settings Section
            VStack(spacing: 16) {
                SecureField("Old Password", text: $oldPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .font(Font.custom("MontserratAlternates-Regular", size: 18))
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .font(Font.custom("MontserratAlternates-Regular", size: 18))

                Button("Update Password") {
                    // Logic to change password
                }
                .font(Font.custom("MontserratAlternates-SemiBold", size: 18))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
            }
            .padding()

            // Forgot Password Section
            Button("Forgot Password?") {
                showForgotPassword = true
                // Logic to handle forgot password
            }
            .font(Font.custom("MontserratAlternates-Regular", size: 18))
            .foregroundColor(.blue)
            .padding()

            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    isFaceIDEnabled = success
                }
            }
        } else {
            // no biometrics
            isFaceIDEnabled = false
        }
    }
}

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        SecurityView()
    }
}

