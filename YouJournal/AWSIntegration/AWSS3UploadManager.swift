//
//  AWSS3UploadManager.swift
//  YouJournal
//
//  Created by Luke Trotman on 22/3/2024.
//

import Foundation
import AWSS3
import CloudKit
import Combine
import AVFoundation


class S3Manager: ObservableObject {
    static let shared = S3Manager()
    
    private init() {}
    
    func uploadVideo(_ videoURL: URL, userId: String, videoRecord: CKRecord, completion: @escaping (Result<(videoURL: URL, thumbnailURL: String), Error>) -> Void) {
        let transferUtility = AWSS3TransferUtility.default()
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        
        uploadExpression.progressBlock = { (task, progress) in
            // Update upload progress if needed
        }
        
        let timestamp = Date().timeIntervalSince1970
        let videoKey = "\(userId)_\(timestamp).mp4"
        let contentType = "video/mp4"
        
        transferUtility.uploadFile(videoURL, bucket: "youjournal-entries-uk", key: videoKey, contentType: contentType, expression: uploadExpression) { (task, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                // Generate the thumbnail
                self.generateThumbnail(from: videoURL) { thumbnailURL in
                    if let thumbnailURL = thumbnailURL {
                        let thumbnailKey = "\(userId)_\(timestamp)_thumbnail.jpg"
                        self.uploadThumbnail(thumbnailURL, bucket: "youjournal-entries-uk", key: thumbnailKey) { result in
                            switch result {
                            case .success(let uploadedThumbnailURL):
                                let videoURL = URL(string: "https://youjournal-entries-uk.s3.eu-west-2.amazonaws.com/\(videoKey)")!
                                
                                // Set the thumbnail URL as a string in the video record
                                videoRecord["thumbnailURL"] = uploadedThumbnailURL.absoluteString
                                completion(.success((videoURL: videoURL, thumbnailURL: uploadedThumbnailURL.absoluteString)))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        completion(.failure(ThumbnailGenerationError.failedToGenerateThumbnail))
                    }
                }
            }
        }
    }
    
    private func generateThumbnail(from videoURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let timeToGenerate = CMTimeMakeWithSeconds(0.5, preferredTimescale: 600) // Thumbnail at 0.5 seconds
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: timeToGenerate)]) { _, cgImage, _, _, _ in
            if let cgImage = cgImage {
                let thumbnailURL = FileManager.default.temporaryDirectory.appendingPathComponent("thumbnail.jpg")
                
                if let jpegData = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8) {
                    try? jpegData.write(to: thumbnailURL)
                    completion(thumbnailURL)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func uploadThumbnail(_ thumbnailURL: URL, bucket: String, key: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let transferUtility = AWSS3TransferUtility.default()
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        
        uploadExpression.progressBlock = { (task, progress) in
            // Update upload progress if needed
        }
        
        transferUtility.uploadFile(thumbnailURL, bucket: bucket, key: key, contentType: "image/jpeg", expression: uploadExpression) { (task, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let uploadedThumbnailURL = URL(string: "https://\(bucket).s3.eu-west-2.amazonaws.com/\(key)")!
                completion(.success(uploadedThumbnailURL))
            }
        }
    }
    
    func downloadVideo(_ videoURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let transferUtility = AWSS3TransferUtility.default()
        let downloadExpression = AWSS3TransferUtilityDownloadExpression()
        
        downloadExpression.progressBlock = { (task, progress) in
            // Update download progress if needed
        }
        
        let downloadURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(videoURL.lastPathComponent)
        
        let bucket = "youjournal-entries-uk"
        let key = videoURL.absoluteString.replacingOccurrences(of: "https://\(bucket).s3.eu-west-2.amazonaws.com/", with: "")
        
        transferUtility.download(to: downloadURL, bucket: bucket, key: key, expression: downloadExpression) { (task, url, data, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(downloadURL, nil)
            }
        }
    }
    
    enum ThumbnailGenerationError: Error {
        case failedToGenerateThumbnail
    }
}
