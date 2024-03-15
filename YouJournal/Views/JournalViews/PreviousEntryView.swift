//
//  PreviousEntry.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import AVKit
import CloudKit

struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)

        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }

    class Coordinator: NSObject {
        let player: AVPlayer

        init(player: AVPlayer) {
            self.player = player
        }

        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            let duration = player.currentItem?.duration.seconds ?? 0

            switch gesture.state {
            case .began, .changed:
                let seekTime = max(0, min(duration, CMTimeGetSeconds(player.currentTime()) + translation.x / 100))
                player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
                gesture.setTranslation(.zero, in: gesture.view)
            case .ended, .cancelled, .failed, .possible:
                break
            @unknown default:
                break
            }
        }
    }
}

struct PreviousEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var s3Manager = S3Manager.shared
    @State private var showDeleteAlert = false
    @State private var player = AVPlayer()
    @State private var isLoading = true
    let entry: JournalEntry

    func deleteEntry() {
        // Your delete functionality here
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
            } else {
                CustomVideoPlayer(player: player)
                    .onTapGesture {
                        if player.timeControlStatus == .playing {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("YJBackIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3, x: 0, y: 0)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3, x: 0, y: 0)
                            .padding()
                    }
                }
                .padding(.top, -70.0)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(entry.date.formatted(.dateTime.day().month().year()) + "'s Entry")
                            .font(.custom("MontserratAlternates-SemiBold", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                        Spacer()
                        Button(action: {
                            // Action to share the video
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 3, x: 0, y: 0)
                        }
                        .padding(.trailing, 20)
                    }

                    Text(entry.date, formatter: itemFormatter)
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)

                    Text("This entry reflects a joyful day spent with family. The park visit was a highlight.")
                        .font(.custom("MontserratAlternates-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)
                        .padding(.bottom, 16)
                }
                .padding(.bottom, 40.0)
                .padding([.leading, .bottom], 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, UIScreen.main.bounds.height * 0.1)
        }
        .onAppear {
            if let videoURL = entry.videoURL {
                s3Manager.downloadVideo(videoURL) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            player = AVPlayer(url: url)
                            player.play()
                            isLoading = false
                        }
                    } else if let error = error {
                        print("Error downloading video: \(error.localizedDescription)")
                        isLoading = false
                    }
                }
            } else {
                isLoading = false
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you want to delete this entry?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteEntry()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("YJBackIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }
            }
        }
    }

    var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}

struct PreviousEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousEntryView(entry: JournalEntry(id: CKRecord.ID(recordName: "sampleEntryID"), date: Date(), thumbnailURL: URL(string: "thumbnail.jpg"), videoURL: URL(string: "https://example.com/video.mp4")))
    }
}
