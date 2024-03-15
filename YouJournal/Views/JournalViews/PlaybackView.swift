//
//  PlaybackView.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import AVKit
import CloudKit
import AWSS3

struct PlaybackView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @StateObject private var s3Manager = S3Manager.shared
    @State private var showConfirmationDialog = false
    @State private var isPlaying = true
    var videoURL: URL
    var prompt: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                VideoPlayerView(videoURL: videoURL, isPlaying: $isPlaying)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        print("PlaybackView received videoURL: \(videoURL.absoluteString)")
                    }
                    .onTapGesture {
                        isPlaying.toggle()
                    }
                
                VStack {
                                  Spacer()
                                  Text(prompt)
                                      .font(.title2)
                                      .foregroundColor(.white)
                                      .padding(.top, 450)
                                      .frame(maxWidth: .infinity)
                                      .background(Color.black.opacity(0.7))
                                      .cornerRadius(10)
                                      .padding(.horizontal, 16)
                                      .shadow(radius: 3)
                                  
                                  Spacer() // Add a Spacer to push the save button down
                    Button(action: {
                        saveJournalEntry()
                    }) {
                        Text("Save")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(11)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showConfirmationDialog = true
                    }) {
                        Image("YJBackIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .confirmationDialog("Are you sure you want to refilm?", isPresented: $showConfirmationDialog, actions: {
            Button("Refilm", role: .destructive) {
                print("Refilming initiated...")
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("You will lose your current journal entry.")
        })
    }
    
    private func saveJournalEntry() {
        print("Saving journal entry...")
        
        guard let userID = getUserID() else {
            print("User ID not found")
            return
        }
        
        let videoRecord = CKRecord(recordType: "video")
        videoRecord.setObject(CKRecord.Reference(recordID: userID, action: .none), forKey: "userID")
        
        s3Manager.uploadVideo(videoURL, userId: userID.recordName, videoRecord: videoRecord) { result in
            switch result {
            case .success(let (uploadedVideoURL, uploadedThumbnailURL)):
                videoRecord["date"] = Date()
                videoRecord["videoURL"] = uploadedVideoURL.absoluteString
                videoRecord["thumbnailURL"] = uploadedThumbnailURL
                
                self.cloudKitManager.saveVideoRecord(videoRecord) { result in
                    switch result {
                    case .success:
                        print("Video record saved successfully")
                        DispatchQueue.main.async {
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .failure(let error):
                        print("Error saving video record: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error saving video journal entry: \(error.localizedDescription)")
            }
        }
    }
    private func getUserID() -> CKRecord.ID? {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found in UserDefaults")
            
            let container = CKContainer(identifier: "iCloud.YouJournalData")
            container.fetchUserRecordID { recordID, error in
                if let error = error {
                    print("Error fetching user record ID: \(error.localizedDescription)")
                    return
                }
                
                guard let recordID = recordID else {
                    print("User record ID not found")
                    return
                }
                
                UserDefaults.standard.set(recordID.recordName, forKey: "userRecordID")
            }
            
            return nil
        }
        
        return CKRecord.ID(recordName: userRecordIDString)
    }
}
struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            print("Video file not found at URL: \(videoURL.path)")
            return AVPlayerViewController()
        }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspectFill
        playerViewController.view.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        playerViewController.view.addGestureRecognizer(panGesture)
        
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if isPlaying {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: VideoPlayerView
        
        init(_ parent: VideoPlayerView) {
            self.parent = parent
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let playerViewController = getAVPlayerViewController(from: gesture.view) else { return }
            let translation = gesture.translation(in: playerViewController.view)
            
            if gesture.state == .began || gesture.state == .changed {
                let currentTime = CMTimeGetSeconds(playerViewController.player?.currentTime() ?? CMTime.zero)
                let duration = CMTimeGetSeconds(playerViewController.player?.currentItem?.duration ?? CMTime.zero)
                let newTime = currentTime + (translation.x / playerViewController.view.bounds.width) * duration
                playerViewController.player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                gesture.setTranslation(.zero, in: playerViewController.view)
            }
        }
        
        private func getAVPlayerViewController(from view: UIView?) -> AVPlayerViewController? {
            guard let view = view else { return nil }
            
            if let playerViewController = view.next as? AVPlayerViewController {
                return playerViewController
            }
            
            return getAVPlayerViewController(from: view.superview)
        }
    }
}

struct PlaybackView_Previews: PreviewProvider {
     static var previews: some View {
         let previewVideoURL = URL(string: "https://youjournal-entries-uk.s3.eu-west-2.amazonaws.com/_497b571f156736a60c54d6ce015ba6bb_1711615611.794921.mp4")!
         PlaybackView(videoURL: previewVideoURL, prompt: "What is one thing you're grateful for today?", onSave: {})
             .environmentObject(CloudKitManager.shared)
     }
 }

