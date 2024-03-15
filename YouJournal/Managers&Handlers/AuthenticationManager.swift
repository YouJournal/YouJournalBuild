//
//  AuthenticationManager.swift
//  YouJournal
//  This File is for User Authentication setup
//  Created by Luke Trotman on 19/3/2024.
//

import Foundation
import AuthenticationServices
import CloudKit
import Security

class AuthenticationManager: NSObject, ObservableObject {
    @Published var isUserAuthenticated: Bool? = nil
    var userID: String?

    private let container = CKContainer(identifier: "iCloud.YouJournalData")
    private let userRecordType = "user"
    private let keychainService = "com.RockyMedia.youjournal.AppleSignInID"
    private let keychainAccount = "appleSignInID"

    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func saveAppleSignInIDToKeychain(_ userIdentifier: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: userIdentifier.data(using: .utf8)!
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            if status == errSecMissingEntitlement {
                print("Error: Missing entitlement to access Keychain")
            } else {
                print("Failed to save Apple Sign In ID to Keychain: \(status)")
            }
        }
    }

    private func retrieveAppleSignInIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var retrievedData: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &retrievedData)

        if status == errSecSuccess, let data = retrievedData as? Data {
            return String(data: data, encoding: .utf8)
        } else if status == errSecMissingEntitlement {
            print("Error: Missing entitlement to access Keychain")
        } else {
            print("Failed to retrieve Apple Sign In ID from Keychain: \(status)")
        }
        return nil
    }

    private func deleteAppleSignInIDFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            if status == errSecMissingEntitlement {
                print("Error: Missing entitlement to access Keychain")
            } else {
                print("Failed to delete Apple Sign In ID from Keychain: \(status)")
            }
        }
    }

    
    private func checkIfUserExists(userIdentifier: String, completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(format: "userID == %@", userIdentifier)
        let query = CKQuery(recordType: userRecordType, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["userID"]
        operation.resultsLimit = 1
        
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error matching user record: \(error)")
                completion(false)
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Error querying user records: \(error)")
                completion(false)
            }
        }
        
        container.publicCloudDatabase.add(operation)
    }
    
    private func createUserRecord(userIdentifier: String, email: String?, fullName: PersonNameComponents?) {
        let userRecord = CKRecord(recordType: userRecordType)
        userRecord["userID"] = userIdentifier
        userRecord["email"] = email
        userRecord["name"] = fullName?.givenName ?? ""
       
        
        container.publicCloudDatabase.save(userRecord) { record, error in
            if let error = error {
                print("Error saving user record: \(error)")
            } else {
                print("User record saved successfully")
            }
        }
    }
    
    func checkAuthenticationState() {
        if fetchUserRecord() != nil {
            isUserAuthenticated = true
        } else {
            isUserAuthenticated = false
        }
    }

    private func fetchUserRecord() -> CKRecord? {
        if let appleSignInID = fetchAppleSignInID() {
            return fetchUserRecordFromCloudKit(withUserID: appleSignInID)
        }
        return nil
    }

    private func fetchAppleSignInID() -> String? {
        return retrieveAppleSignInIDFromKeychain()
    }

    private func fetchUserRecordFromCloudKit(withUserID userID: String) -> CKRecord? {
        let container = CKContainer(identifier: "iCloud.YouJournalData")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userID)
        
        var userRecord: CKRecord?
        let semaphore = DispatchSemaphore(value: 0)
        
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                print("Error fetching user record: \(error.localizedDescription)")
            } else {
                userRecord = record
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return userRecord
    }
}

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            DispatchQueue.main.async { [weak self] in
                let userIdentifier = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                
                self?.checkIfUserExists(userIdentifier: userIdentifier) { exists in
                    if !exists {
                        self?.createUserRecord(userIdentifier: userIdentifier, email: email, fullName: fullName)
                    }
                    
                    self?.saveAppleSignInIDToKeychain(userIdentifier)
                    
                    self?.userID = userIdentifier // Store the user's ID
                    
                    self?.isUserAuthenticated = true
                }
            }
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            print("Sign in with Apple authorization failed: \(error)")
            self.isUserAuthenticated = false
            self.deleteAppleSignInIDFromKeychain()
        }
    }
    
    private func storeAppleSignInID(_ userIdentifier: String) {
        saveAppleSignInIDToKeychain(userIdentifier)
    }
}

extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found in the app's window scene")
        }
        return window
    }
}
