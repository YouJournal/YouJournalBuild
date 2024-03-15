//
//  JournalInput.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

//
//  JournalInput.swift
//  YouJournal
//
//  Created by Luke Trotman on 15/3/2024.
//

import SwiftUI
import AVFoundation

// MARK: - CameraViewModel
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var flashOn = false
    @Published var isUsingFrontCamera = true
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var recordedVideoURL: URL?
    @Published var recordingProgress: CGFloat = 0.0
    
    
    private let movieOutput = AVCaptureMovieFileOutput()
    
    func configure() {
        checkPermissions()
        setupSession()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                } else {
                    self.alertMessage = "Camera access is required to record videos."
                    self.showingAlert = true
                }
            }
        case .denied, .restricted:
            self.alertMessage = "Camera access is denied or restricted. Please enable it in settings."
            self.showingAlert = true
        @unknown default:
            fatalError("Unknown authorization status for camera access.")
        }
    }
    
    private func setupSession() {
        DispatchQueue.main.async {
            self.session.beginConfiguration()
            self.session.inputs.forEach { self.session.removeInput($0) }
            
            self.addVideoInput()
            self.addAudioInput()
            self.addMovieOutput()
            
            self.session.commitConfiguration()
            
            // Move the startSession() call outside the configuration block
            self.startSession()
        }
    }
    
    private func addVideoInput() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: isUsingFrontCamera ? .front : .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            self.alertMessage = "Unable to setup video input."
            self.showingAlert = true
            return
        }
        
        self.session.addInput(videoDeviceInput)
    }
    
    private func addAudioInput() {
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice),
              session.canAddInput(audioDeviceInput) else {
            self.alertMessage = "Unable to setup audio input."
            self.showingAlert = true
            return
        }
        
        self.session.addInput(audioDeviceInput)
    }
    
    private func addMovieOutput() {
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
    }
    
    func startSession() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { // Delay added
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func toggleFlash() {
        flashOn.toggle()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: isUsingFrontCamera ? .front : .back) else {
            return
        }

        do {
            try videoDevice.lockForConfiguration()

            if flashOn {
                try videoDevice.setTorchModeOn(level: 1.0)
            } else {
                videoDevice.torchMode = .off
            }

            videoDevice.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error.localizedDescription)")
        }
    }
    
    func stopRecordingAndResetProgress() {
        movieOutput.stopRecording()
        recordingProgress = 0.0
    }
    
    func switchCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        var newInput: AVCaptureDeviceInput?
        var newPosition: AVCaptureDevice.Position?
        
        if currentInput.device.position == .back {
            newPosition = .front
        } else {
            newPosition = .back
        }
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition!) else { return }
        
        do {
            newInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            print("Error creating capture device input: \(error.localizedDescription)")
            session.addInput(currentInput)
            session.commitConfiguration()
            return
        }
        
        if let newInput = newInput {
            session.addInput(newInput)
            DispatchQueue.main.async {
                self.isUsingFrontCamera = (newPosition == .front)
            }
        } else {
            session.addInput(currentInput)
        }
        
        session.commitConfiguration()
    }
    
    func startRecording() {
        let timestamp = Date().timeIntervalSince1970
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("video_\(timestamp).mov")
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput.stopRecording()
    }
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            
            let underlyingError = error as NSError
            if underlyingError.code == NSFileWriteInvalidFileNameError {
                print("Invalid file name or path")
            } else if underlyingError.code == NSFileWriteOutOfSpaceError {
                print("Not enough disk space available")
            } else {
                print("Other file write error: \(underlyingError.code)")
            }
        } else {
            recordedVideoURL = outputFileURL
            saveRecordedVideoToLocalDirectory(url: outputFileURL)
        }
    }
    
    private func saveRecordedVideoToLocalDirectory(url: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Date().timeIntervalSince1970
        let destinationURL = documentsDirectory.appendingPathComponent("recorded_video_\(timestamp).mp4")
        
        do {
            try FileManager.default.moveItem(at: url, to: destinationURL)
            DispatchQueue.main.async {
                self.recordedVideoURL = destinationURL // Ensure this is the URL passed to PlaybackView
            }
        } catch {
            print("Error saving video to local directory: \(error.localizedDescription)")
        }
    }
}

// MARK: - CameraPreview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer when the view updates
    }
}

// MARK: - RecordJournalView
struct RecordJournalView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var isRecording = false
    @State private var currentPromptIndex = 0
    @State private var showPlaybackView = false
    @State private var recordedVideoURL: URL?
    var onSave: () -> Void
    
    let maxRecordingDuration: TimeInterval = 60.0
    let prompts = [
        "What is one thing you're grateful for today?",
        "What made you smile today?",
        "Describe a favorite memory from this week."
    ]
    
    var body: some View {
           ZStack {
               CameraPreview(session: cameraViewModel.session)
                   .edgesIgnoringSafeArea(.all)
               
               VStack {
                   HStack {
                       backButton
                       Spacer()
                   }
                   .padding(.top, 10)
                   
                   Spacer()
                   
                   TabView(selection: $currentPromptIndex) {
                       ForEach(0..<prompts.count, id: \.self) { index in
                           promptOverlay(prompt: prompts[index])
                       }
                   }
                   .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                   .frame(maxWidth: .infinity, maxHeight: 200)
                   .disabled(isRecording)
                   .padding(.top, 450) // Adjust the bottom padding to move the prompt overlay down
                   
                   Spacer()
                   
                   HStack {
                       flashButton
                       Spacer()
                       recordButton
                       Spacer()
                       cameraFlipButton
                   }
                   .padding(.horizontal, 100)
                   .padding(.bottom, 20)
               }
           }
        .navigationBarHidden(true)
        .onAppear {
            cameraViewModel.configure()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
        .alert(isPresented: $cameraViewModel.showingAlert) {
            Alert(title: Text("Error"), message: Text(cameraViewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showPlaybackView) {
            if let videoURL = recordedVideoURL {
                PlaybackView(videoURL: videoURL, prompt: prompts[currentPromptIndex], onSave: {
                    presentationMode.wrappedValue.dismiss()
                    onSave()
                })
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("YJBackIcon")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 36.0, height: 36.0)
                .shadow(radius: 3)
                .padding(5)
        }
        .padding(.leading, 20)
    }
    
    private var flashButton: some View {
        Button(action: {
            cameraViewModel.toggleFlash()
        }) {
            Image(systemName: cameraViewModel.flashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
    }
    
    private var cameraFlipButton: some View {
        Button(action: {
            cameraViewModel.switchCamera()
        }) {
            Image(systemName: "camera.rotate")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
    }
    
    private var recordButton: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 5)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: cameraViewModel.recordingProgress)
                .stroke(Color.white, lineWidth: 5)
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle" : "record.circle")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(isRecording ? .red : .white)
                    .shadow(radius: 3)
            }
        }
    }
    
    private func promptOverlay(prompt: String) -> some View {
        Text(prompt)
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .shadow(radius: 3)
    }
    
    private func startRecording() {
        isRecording = true
        cameraViewModel.startRecording()
        
        // Start updating the recording progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            cameraViewModel.recordingProgress += 0.1 / maxRecordingDuration
            
            if cameraViewModel.recordingProgress >= 1.0 {
                timer.invalidate()
                stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        cameraViewModel.stopRecordingAndResetProgress()
        
        // Wait for the recordedVideoURL to be updated in the CameraViewModel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recordedVideoURL = self.cameraViewModel.recordedVideoURL
            print("Recorded video URL: \(self.recordedVideoURL?.absoluteString ?? "nil")")
            
            // Show the playback view
            self.showPlaybackView = true
        }
    }    
}

// MARK: - RecordJournalView_Previews
struct RecordJournalView_Previews: PreviewProvider {
       static var previews: some View {
           RecordJournalView(onSave: {})
       }
   }
