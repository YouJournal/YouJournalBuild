//
//  SignUp.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String?
    @State private var email: String = ""
    @State private var password: String = ""

    // Initialize SignUpView with an optional name parameter and a default value of nil
    init(name: String? = nil) {
        self._name = State(initialValue: name)
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon") // Use "YJBackIcon" if you have a custom back icon
                        .foregroundColor(.black)
                        .padding()
                }

                Spacer()
            }

            Spacer()
            
            Text("Create account")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 32))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .padding(.top, 20)

            Text("Please enter the following...")
                .font(Font.custom("MontserratAlternates-Regular", size: 16))
                .foregroundColor(Color(red: 0.50, green: 0.50, blue: 0.50))
                .padding(.bottom, 20)
            
            // Use if-let to conditionally display TextField for name if available
            if let unwrappedName = name {
                TextField("Name", text: Binding(get: { unwrappedName }, set: { name = $0 }))
                    .textFieldStyle()
                    .padding(.horizontal)
            }

            TextField("Email", text: $email)
                .textFieldStyle()
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle()
                .padding(.horizontal)

            Button(action: signUp) {
                Text("Sign Up")
                    .buttonStyle()
            }
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            HStack {
                Text("Already have an account?")
                    .font(Font.custom("MontserratAlternates-Regular", size: 16))
                Button(action: { /* Navigate to Sign In View */ }) {
                    Text("Sign In")
                        .font(Font.custom("MontserratAlternates-Bold", size: 16))
                        .underline()
                        .foregroundColor(Color.blue)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    func signUp() {
        // TODO: Implement sign-up logic with backend
        print("Sign up logic to be implemented")
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .font(Font.custom("MontserratAlternates-Regular", size: 16))
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 0.5))
    }

    func buttonStyle() -> some View {
        self
            .font(Font.custom("MontserratAlternates-SemiBold", size: 20))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(8)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(name: "Chelsea") // Preview with a default name
    }
}




