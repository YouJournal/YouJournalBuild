//
//  SignIn.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View, Hashable {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }
                .padding(.leading)
                Spacer()
            }
            .padding(.top, 44)

            Spacer()

            Text("Welcome Back")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 32))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .padding(.top, 40)
                .padding(.bottom, 20)

            Image("SignUp")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .shadow(radius: 20)

            SignInWithAppleButton { request in
                // Optional: Configure request here if needed
            } onCompletion: { result in
                // Handle the result of the Sign in with Apple attempt
                switch result {
                case .success(let authResults):
                    // Handle successful sign-in with Apple
                    print(authResults)
                    // Navigate to JournalHomeView or perform any additional actions
                case .failure(let error):
                    // Handle errors during sign-in attempt
                    print(error.localizedDescription)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(8)
            .padding()

            Spacer()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
    func hash(into hasher: inout Hasher) {
        // Since SignInView doesn't have any unique properties,
        // you can provide a constant hash value
        hasher.combine(0)
    }
    
    static func == (lhs: SignInView, rhs: SignInView) -> Bool {
        // Since SignInView doesn't have any properties to compare for equality,
        // you can always return true
        return true
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
