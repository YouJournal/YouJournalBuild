//
//  Onboarding1.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct Onboarding1: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    let imageName = "Chart"
    
    let name: String
    
    let preferences: [String]
    
    var body: some View {
        
        VStack {
            
            Text("Ready To Discover Your Unique Narrative?")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 25))
                .frame(width: 310.0, height: 150.0)
                .tracking(0.50)
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .multilineTextAlignment(.center)
                .padding(.top, 75)
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 500, height: 500)
                .shadow(radius: 10)
            
            Spacer()
            
            NavigationLink(destination: CompleteSignUpView(name: name, preferences: preferences)) {
                Text("Let's Go!")
                    .font(Font.custom("MontserratAlternates-Regular", size: 18))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                    .frame(height: 54)
                    .frame(maxWidth: 350)
                    .background(Color.black)
                    .cornerRadius(11)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("YJBackIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundColor(.black)
            }
        )
    }
}

struct Onboarding1_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding1(name: "John Doe", preferences: ["Preference 1", "Preference 2"])
    }
}





