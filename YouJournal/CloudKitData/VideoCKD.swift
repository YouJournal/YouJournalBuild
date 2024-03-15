import CloudKit

// Define the CKDataModel for the Video record type
struct CKVideo {
    static let recordType = "video"
    
    struct Field {
        static let id = "___recordID"
        static let date = "date"
        static let thumbnailURL = "thumbnailURL"
        static let userID = "userID"
        static let videoURL = "videoURL"
    }
}

// Define a helper method to create a CKRecord from a Video object
extension Video {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKVideo.recordType)
        
        record[CKVideo.Field.id] = id as CKRecordValue
        record[CKVideo.Field.date] = Date() as CKRecordValue
        record[CKVideo.Field.thumbnailURL] = "" as CKRecordValue // Set the appropriate thumbnail URL
        record[CKVideo.Field.userID] = CKRecord.Reference(recordID: CKRecord.ID(recordName: ""), action: .none) // Set the appropriate user ID
        record[CKVideo.Field.videoURL] = "" as CKRecordValue // Set the appropriate video URL
        
        return record
    }
}
