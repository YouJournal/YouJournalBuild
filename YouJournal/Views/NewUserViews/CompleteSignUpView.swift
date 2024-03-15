//
//  SignUpOptionsView.swift
//  YouJournal
//
//  Created by Luke Trotman on 16/3/2024.
//

import SwiftUI
import AuthenticationServices
import CloudKit
import Combine

struct CompleteSignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToJournalHome = false
    @State private var navigateToSignIn = false
    @State private var userRecord: CKRecord?
    @StateObject private var viewModel: SignInWithAppleViewModel
    
    // Initialize the view model with the collected user data
    init(name: String, preferences: [String]) {
        _viewModel = StateObject(wrappedValue: SignInWithAppleViewModel(name: name, preferences: preferences))
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Text("Complete Account")
                .font(Font.custom("MontserratAlternates-SemiBold", size: 32))
                .foregroundColor(.black)
                .padding(.top, 36.0)
            
            Image("HandShake")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 400)
                .padding(.vertical, 30)
                .shadow(radius: 20)
            
            SignInWithAppleButton(.signUp) { request in
                viewModel.signInWithApple(request: request)
            } onCompletion: { result in
                viewModel.handleSignInResult(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(8)
            .padding(.horizontal, 75.0)
            .padding(.bottom, 30)
            
            HStack {
                Text("Already have an account?")
                    .font(Font.custom("MontserratAlternates-Regular", size: 16))
                    .foregroundColor(Color("TextColor"))
                
                Button("Log In") {
                    navigateToSignIn = true
                }
                .font(Font.custom("MontserratAlternates-Bold", size: 16))
                .foregroundColor(.blue)
            }
            .padding(.bottom, 50)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("YJBackIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }
            }
        }
        .background(NavigationLink(value: SignInView()) {
            EmptyView()
        })
        .navigationDestination(isPresented: $navigateToSignIn) {
            SignInView()
        }
        .navigationDestination(isPresented: $navigateToJournalHome) {
                    if let record = userRecord {
                        JournalHomeView(userRecord: record)
                    } else {
                        Text("User record not found")
                    }
                }
                .onChange(of: viewModel.userRecord) { newValue, _ in
                    userRecord = newValue
                    if newValue != nil {
                        navigateToJournalHome = true
                    }
                }
            }
    class SignInWithAppleViewModel: ObservableObject {
        @Published var userRecord: CKRecord?
        private let name: String
        private let preferences: [String]
        
        init(name: String, preferences: [String]) {
            self.name = name
            self.preferences = preferences
        }
        
        func signInWithApple(request: ASAuthorizationAppleIDRequest) {
            request.requestedScopes = [.fullName, .email]
        }
        
        func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
            switch result {
            case .success(let authorization):
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let userIdentifier = appleIDCredential.user
                    let email = appleIDCredential.email
                    
                    // Fetch the user's record from CloudKit
                    fetchUserRecord(userIdentifier: userIdentifier)
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let error):
                                print("Error fetching user record: \(error.localizedDescription)")
                            case .finished:
                                break
                            }
                        } receiveValue: { [weak self] userRecord in
                            guard let self = self else { return }
                            
                            if let record = userRecord {
                                // User record exists, update the custom fields
                                let updatedRecord = record
                                updatedRecord["email"] = email
                                updatedRecord["name"] = appleIDCredential.fullName?.givenName ?? ""
                                updatedRecord["preferences"] = self.preferences
                                
                                // Save the updated user record
                                self.saveUserRecord(updatedRecord)
                                    .receive(on: DispatchQueue.main)
                                    .sink { completion in
                                        switch completion {
                                        case .failure(let error):
                                            print("Error saving user record: \(error.localizedDescription)")
                                        case .finished:
                                            break
                                        }
                                    } receiveValue: { [weak self] savedRecord in
                                        self?.userRecord = savedRecord
                                        self?.saveUserStateToUserDefaults(savedRecord)
                                    }
                                    .store(in: &self.cancellables)
                            } else {
                                // User record doesn't exist, log an error or handle the scenario appropriately
                                print("User record not found for identifier: \(userIdentifier)")
                            }
                        }
                        .store(in: &self.cancellables)
                }
            case .failure(let error):
                print("Sign in with Apple failed: \(error.localizedDescription)")
            }
        }
        
        private func saveUserRecord(_ userRecord: CKRecord) -> AnyPublisher<CKRecord, Error> {
            let database = CKContainer(identifier: "iCloud.YouJournalData").privateCloudDatabase
            
            return Future { promise in
                database.save(userRecord) { savedRecord, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let savedRecord = savedRecord {
                        promise(.success(savedRecord))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        
        private func fetchUserRecord(userIdentifier: String) -> AnyPublisher<CKRecord?, Error> {
            let container = CKContainer(identifier: "iCloud.YouJournalData")
            
            return Future { promise in
                container.fetchUserRecordID { recordID, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let recordID = recordID {
                        let privateDatabase = container.privateCloudDatabase
                        privateDatabase.fetch(withRecordID: recordID) { record, error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(record))
                            }
                        }
                    } else {
                        promise(.success(nil))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        
        private func saveUserStateToUserDefaults(_ record: CKRecord) {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: record, requiringSecureCoding: true)
                UserDefaults.standard.set(data, forKey: "userRecord")
                UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
            } catch {
                print("Failed to save user state to UserDefaults: \(error.localizedDescription)")
            }
        }
        
        private var cancellables = Set<AnyCancellable>()
    }
    
    struct CompleteSignUpView_Previews: PreviewProvider {
        static var previews: some View {
            CompleteSignUpView(name: "John Doe", preferences: ["Preference 1", "Preference 2"])
        }
    }
}
