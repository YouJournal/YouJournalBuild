import CloudKit
import Foundation

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private init() {}
    
    private let container = CKContainer(identifier: "iCloud.YouJournalData")
    private var publicDatabase: CKDatabase?
    private var privateDatabase: CKDatabase?
    
    func setupContainer(completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure the user is logged into iCloud
        container.accountStatus { [weak self] (accountStatus, error) in
            guard let self = self else { return }
            
            if let error = error {
                // Handle the error
                print("Error retrieving iCloud account status: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            switch accountStatus {
            case .available:
                // User is logged in, set up the databases
                self.publicDatabase = self.container.publicCloudDatabase
                self.privateDatabase = self.container.privateCloudDatabase
                
                // Verify that the private database is initialized
                guard self.privateDatabase != nil else {
                    let error = CloudKitError.databaseNotAvailable
                    print("Private database is not available")
                    completion(.failure(error))
                    return
                }
                
                // Print statements to check if the databases are set up correctly
                print("Public database: \(String(describing: self.publicDatabase))")
                print("Private database: \(String(describing: self.privateDatabase))")
                
                print("CloudKit container set up successfully")
                completion(.success(()))
                
            case .noAccount:
                // User is not logged into iCloud
                let error = CloudKitError.noAccount
                print("User is not logged into iCloud")
                completion(.failure(error))
                
            case .couldNotDetermine:
                // Unable to determine account status
                let error = CloudKitError.couldNotDetermine
                print("Unable to determine iCloud account status")
                completion(.failure(error))
                
            case .restricted:
                // iCloud account is restricted
                let error = CloudKitError.restricted
                print("iCloud account is restricted")
                completion(.failure(error))
                
            case .temporarilyUnavailable:
                // iCloud temporarily unavailable, try again later
                let error = CloudKitError.temporarilyUnavailable
                print("iCloud temporarily unavailable, please try again later")
                completion(.failure(error))
                
            @unknown default:
                // Unknown account status
                let error = CloudKitError.unknown
                print("Unknown iCloud account status")
                completion(.failure(error))
            }
        }
    }
    
    // Function to save video record
    func saveVideoRecord(_ videoRecord: CKRecord, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        guard let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }
        
        privateDatabase.save(videoRecord) { record, error in
            if let error = error {
                completion(.failure(error))
            } else if let record = record {
                completion(.success(record))
            }
        }
    }
    
    func fetchUserJournalEntries(userID: CKRecord.ID, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        guard let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }

        let predicate = NSPredicate(format: "userID == %@", CKRecord.Reference(recordID: userID, action: .none))
        let query = CKQuery(recordType: "video", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["date", "thumbnailURL", "videoURL"]
        operation.resultsLimit = CKQueryOperation.maximumResults

        var fetchedRecords: [CKRecord] = []

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error fetching record with ID \(recordID.recordName): \(error.localizedDescription)")
            }
        }

        operation.queryResultBlock = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let cursor):
                if cursor == nil {
                    // All results fetched, return the records
                    completion(.success(fetchedRecords))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }

        privateDatabase.add(operation)
    }

    // Function to fetch a specific video journal entry
    func fetchVideoJournalEntry(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        guard let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }
        
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                completion(.failure(error))
            } else if let record = record {
                completion(.success(record))
            }
        }
    }
    
    // Function to delete a video journal entry
    func deleteVideoJournalEntry(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { recordID, error in
            if let error = error {
                completion(.failure(error))
            } else if recordID != nil {
                completion(.success(()))
            }
        }
    }
    
    // Function to create a user record in CloudKit
    func createUserRecord(userID: CKRecord.ID, name: String, email: String, preferences: [String], completion: @escaping (Result<CKRecord, Error>) -> Void) {
        guard let publicDatabase = publicDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }

        let userRecord = CKRecord(recordType: "Users", recordID: userID)
        userRecord["name"] = name
        userRecord["email"] = email
        userRecord["preferences"] = preferences

        publicDatabase.save(userRecord) { record, error in
            if let error = error {
                completion(.failure(error))
            } else if let record = record {
                completion(.success(record))
            }
        }
    }
    
    // Function to fetch a user record from CloudKit
    func fetchUserRecord(userID: CKRecord.ID, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        guard let publicDatabase = publicDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }
        
        publicDatabase.fetch(withRecordID: userID) { record, error in
            if let error = error {
                completion(.failure(error))
            } else if let record = record {
                completion(.success(record))
            }
        }
    }
    
    // Function to update a user record in CloudKit
    func updateUserRecord(userRecord: CKRecord, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        guard let publicDatabase = publicDatabase else {
            completion(.failure(CloudKitError.databaseNotAvailable))
            return
        }
        
        publicDatabase.save(userRecord) { record, error in
            if let error = error {
                completion(.failure(error))
            } else if let record = record {
                completion(.success(record))
            }
        }
    }
}

enum CloudKitError: Error {
    case databaseNotAvailable
    case noAccount
    case couldNotDetermine
    case restricted
    case temporarilyUnavailable
    case unknown
}

