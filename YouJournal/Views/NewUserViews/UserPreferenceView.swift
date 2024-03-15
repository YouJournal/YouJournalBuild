//
//  UserPreference.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI

struct UserPreferenceView: View {
    let userName: String
    @State private var selection: Set<String> = []
    @Environment(\.presentationMode) private var presentationMode

    let options = ["Understand Yourself", "Ignite Your Motivation", "Healing & Resilience", "Just Explore"]
    let optionImages = ["Understand Yourself": "Wierdy-1", "Ignite Your Motivation": "Wierdy-2", "Healing & Resilience": "Wierdy-3", "Just Explore": "Wierdy-4"]

    @State private var isNextButtonPressed = false

    var body: some View {
        NavigationView {
            VStack {
                titleView
                
                Text("Select All That Apply")
                    .font(.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(Color("YJBlue"))
                    .padding(.bottom, 30)

                Spacer()

                optionsGrid

                Spacer()

                NavigationLink(destination: Onboarding1(name: userName, preferences: Array(selection))) {
                    Text("Next")
                        .font(.custom("MontserratAlternates-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selection.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(11)
                }
                .disabled(selection.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }
            }
        }
    }

    private var titleView: some View {
        HStack {
            Text("\(userName), Choose Your Focus")
                .font(.custom("MontserratAlternates-SemiBold", size: 25))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(.vertical)
    }

    private var optionsGrid: some View {
        LazyVGrid(columns: [GridItem(.fixed(170)), GridItem(.fixed(170))], spacing: 20) {
            ForEach(options, id: \.self) { option in
                optionButton(option: option)
            }
        }
        .padding()
    }

    private func optionButton(option: String) -> some View {
        Button(action: {
            if selection.contains(option) {
                selection.remove(option)
            } else {
                selection.insert(option)
            }
        }) {
            ZStack {
                if selection.contains(option), let imageName = optionImages[option] {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 140)
                }
                VStack {
                    if selection.contains(option) {
                        Spacer()
                    }
                    Text(option)
                        .font(.custom("MontserratAlternates-Regular", size: 18))
                        .foregroundColor(selection.contains(option) ? .white : .black)
                        .padding(.bottom, selection.contains(option) ? 8 : 0)
                        .fontWeight(selection.contains(option) ? .bold : .regular)
                        .shadow(color: selection.contains(option) ? .black : .clear, radius: 5, x: 0, y: 3)
                }
            }
            .frame(width: 170, height: 170)
            .background(selection.contains(option) ? Color.blue : Color.white)
            .cornerRadius(11)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .accessibilityLabel(option)
    }
}

struct UserPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        UserPreferenceView(userName: "John Doe")
    }
}












