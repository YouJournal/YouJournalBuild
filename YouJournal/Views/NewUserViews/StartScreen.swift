//
//  StartScreen.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//


import SwiftUI

struct StartScreen: View {
    @State private var navigateToGetNameView = false
    @State private var navigateToSignInView = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Text("YouJournal")
                    .font(.custom("MontserratAlternates-Regular", size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 50.0)

                Image("Facilities")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500, height: 400)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)

                Text("The World's First\nAI Powered Video Journal\nThat Adapts To You")
                    .font(.custom("MontserratAlternates-Regular", size: 20))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))

                Spacer()

                Button(action: {
                    navigateToGetNameView = true
                }) {
                    VStack {
                        Spacer()
                        Text("Start")
                            .font(.custom("MontserratAlternates-Regular", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(11)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 70.0)

                Button("Already have an account? Log In") {
                    navigateToSignInView = true
                }
                .font(.custom("MontserratAlternates-Regular", size: 14))
                .foregroundColor(Color("YJBlue"))
                .padding(.bottom, 30)

                NavigationLink(destination: GetNameView(), isActive: $navigateToGetNameView) {
                    EmptyView()
                }
                .hidden()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
