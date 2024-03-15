//  GetName.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct GetNameView: View {
    @State private var name: String = ""
    @State private var navigateToUserPreferenceView = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("What Should We Call You?")
                .font(.custom("MontserratAlternates-SemiBold", size: 25))
                .tracking(0.50)
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20.0)
                .padding(.top, 1)
            
            TextField("Enter your name", text: $name)
                .font(.custom("MontserratAlternates-Regular", size: 16))
                .padding(16)
                .foregroundColor(Color(red: 0.45, green: 0.49, blue: 0.49))
                .background(Color.white)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color(red: 0.11, green: 0.11, blue: 0.11), lineWidth: 1)
                )
                .padding([.leading, .trailing], 30)
                .padding(.top, 10)
            
            Image("BoostYourAbility") // Replace with your actual image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400.0, height: 400.0)
                .padding([.leading, .trailing], 0.0)
                .padding(.top, 30.0)
                .shadow(radius: 20)
            
            Spacer()
            
            Button(action: {
                navigateToUserPreferenceView = true
            }) {
                Text("Next")
                    .font(.custom("MontserratAlternates-Regular", size: 18))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                    .frame(maxWidth: .infinity, maxHeight: 54)
                    .background(name.isEmpty ? Color.gray : Color.black)
                    .cornerRadius(11)
                    .padding([.leading, .trailing], 40)
                    .padding(.bottom, 50)
                    .disabled(name.isEmpty)
            }
            .overlay(
                Button(action: {
                    navigateToUserPreferenceView = true
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: 54)
                .padding([.leading, .trailing], 40)
                .disabled(name.isEmpty)
            )
            
            NavigationLink(destination: UserPreferenceView(userName: name), isActive: $navigateToUserPreferenceView) {
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarBackButtonHidden(true)
                }
            }

struct GetNameView_Previews: PreviewProvider {
    static var previews: some View {
        GetNameView()
    }
}



