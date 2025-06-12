//
//  DualCameraViewModel.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import Foundation
import AVKit
import AVFoundation
import Combine

enum RecordingState: Equatable {
    case idle
    case preparing
    case recording
    case finished(frontURL: URL, backURL: URL)
    case failed(Error)
    
    // Implement Equatable manually because Error doesn't conform to Equatable
    static func == (lhs: RecordingState, rhs: RecordingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.preparing, .preparing):
            return true
        case (.recording, .recording):
            return true
        case let (.finished(lhsFront, lhsBack), .finished(rhsFront, rhsBack)):
            return lhsFront == rhsFront && lhsBack == rhsBack
        case (.failed, .failed):
            // Can't compare errors directly, so we consider all failed states equal
            return true
        default:
            return false
        }
    }
}


class DualCameraManager: NSObject, ObservableObject {
    private let multiCamSession = AVCaptureMultiCamSession()
    private let sessionQueue = DispatchQueue(label: "com.dualcam.session.queue")
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var frontCameraOutput: AVCaptureMovieFileOutput?
    private var backCameraOutput: AVCaptureMovieFileOutput?
    
    
    @Published var previewLayerFront: AVCaptureVideoPreviewLayer?
    @Published var previewLayerBack: AVCaptureVideoPreviewLayer?
    @Published var recordingState: RecordingState = .idle {
        didSet {
            DispatchQueue.main.async {
                switch self.recordingState {
                case .recording:
                    self.isRecording = true
                    self.startTimer()
                case .finished(let frontURL, let backURL):
                    self.isRecording = false
                    self.stopTimer()
                    self.recordingFinishedHandler?(frontURL, backURL)
                case .failed(let error):
                    self.isRecording = false
                    self.stopTimer()
                    print("Recording failed: \(error.localizedDescription)")
                case .idle, .preparing:
                    self.isRecording = false
                    self.stopTimer()
                }
                self.objectWillChange.send()
            }
        }

    }

    var recordingFinishedHandler: ((URL, URL) -> Void)?

    private var frontRecordingURL: URL?
    private var backRecordingURL: URL?
    
    // In DualCameraManager.swift

    @Published var recordingDuration = 0
    @Published var isRecording = false

    private var timerCancellable: Cancellable?
    private var stopRecordingWorkItem: DispatchWorkItem?

    
    override init() {
        super.init()
        setupSession()
    }
    
    func startRecordingWithTimer() {
        startRecording()
        isRecording = true

        stopRecordingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.stopRecording()
        }
        stopRecordingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: workItem)
    }

    func stopRecordingManually() {
        stopRecordingWorkItem?.cancel()
        stopRecordingWorkItem = nil

        stopRecording()
        isRecording = false
    }

    private func startTimer() {
        recordingDuration = 0
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recordingDuration += 1
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        recordingDuration = 0
    }

    
    
    private func setupSession() {
        sessionQueue.async {
            guard AVCaptureMultiCamSession.isMultiCamSupported else {
                print("MultiCam not supported on this device")
                return
            }
            
            self.configureSession()
        }
    }
    
    
    private func configureSession() {
        sessionQueue.async {
            guard AVCaptureMultiCamSession.isMultiCamSupported else {
                print("MultiCam not supported on this device")
                return
            }

            self.multiCamSession.beginConfiguration()
            defer {
                self.multiCamSession.commitConfiguration()

                // 👇 Moved PREVIEW SETUP HERE — immediately after commitConfiguration
                DispatchQueue.main.async {
                    self.previewLayerFront = AVCaptureVideoPreviewLayer(session: self.multiCamSession)
                    self.previewLayerFront?.connection?.videoOrientation = .portrait
                    self.previewLayerFront?.videoGravity = .resizeAspectFill

                    self.previewLayerBack = AVCaptureVideoPreviewLayer(session: self.multiCamSession)
                    self.previewLayerBack?.connection?.videoOrientation = .portrait
                    self.previewLayerBack?.videoGravity = .resizeAspectFill
                }

                // 👇 Start running AFTER preview layers are set
                self.sessionQueue.async {
                    if !self.multiCamSession.isRunning {
                        self.multiCamSession.startRunning()
                    }
                }
            }

            // === CAMERA INPUT/OUTPUT SETUP ===

            // Front camera
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let frontInput = try? AVCaptureDeviceInput(device: frontCamera) else {
                print("Failed to setup front camera")
                return
            }

            let frontOutput = AVCaptureMovieFileOutput()
            guard self.multiCamSession.canAddInput(frontInput) && self.multiCamSession.canAddOutput(frontOutput) else {
                print("Failed to add front input/output")
                return
            }

            self.multiCamSession.addInputWithNoConnections(frontInput)
            self.multiCamSession.addOutputWithNoConnections(frontOutput)

            // Back camera
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let backInput = try? AVCaptureDeviceInput(device: backCamera) else {
                print("Failed to setup back camera")
                return
            }

            let backOutput = AVCaptureMovieFileOutput()
            guard self.multiCamSession.canAddInput(backInput) && self.multiCamSession.canAddOutput(backOutput) else {
                print("Failed to add back input/output")
                return
            }

            self.multiCamSession.addInputWithNoConnections(backInput)
            self.multiCamSession.addOutputWithNoConnections(backOutput)

            // Connections
            let frontCameraPort = frontInput.ports.first!
            let frontConnection = AVCaptureConnection(inputPorts: [frontCameraPort], output: frontOutput)
            guard self.multiCamSession.canAddConnection(frontConnection) else {
                print("Failed to add front camera connection")
                return
            }
            self.multiCamSession.addConnection(frontConnection)

            let backCameraPort = backInput.ports.first!
            let backConnection = AVCaptureConnection(inputPorts: [backCameraPort], output: backOutput)
            guard self.multiCamSession.canAddConnection(backConnection) else {
                print("Failed to add back camera connection")
                return
            }
            self.multiCamSession.addConnection(backConnection)

            // Save references
            self.frontCameraInput = frontInput
            self.backCameraInput = backInput
            self.frontCameraOutput = frontOutput
            self.backCameraOutput = backOutput
        }
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Camera access denied")
                }
                self.sessionQueue.resume()
            }
        default:
            print("Camera access denied")
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if !granted {
                    print("Microphone access denied")
                }
                self.sessionQueue.resume()
            }
        default:
            print("Microphone access denied")
        }
    }
    
    func startRecording() {
        sessionQueue.async {
            guard self.recordingState != .recording else { return }
            
            DispatchQueue.main.async {
                self.recordingState = .preparing
            }

            let tempDir = FileManager.default.temporaryDirectory
            let frontURL = tempDir.appendingPathComponent("front_\(UUID().uuidString).mov")
            let backURL = tempDir.appendingPathComponent("back_\(UUID().uuidString).mov")
            
            DispatchQueue.main.async {
                self.frontRecordingURL = frontURL
                self.backRecordingURL = backURL
            }
            
            self.frontCameraOutput?.startRecording(to: frontURL, recordingDelegate: self)
            self.backCameraOutput?.startRecording(to: backURL, recordingDelegate: self)
            
            DispatchQueue.main.async {
                self.recordingState = .recording
            }
        }
    }
    
    func stopRecording() {
        sessionQueue.async {
            guard self.recordingState == .recording else { return }
            
            self.frontCameraOutput?.stopRecording()
            self.backCameraOutput?.stopRecording()
        }
    }
    
    private func saveToCameraRoll(frontURL: URL, backURL: URL) {
        // Save to local storage or upload to backend
        // For this example, we'll just keep the files in the temp directory
        // In a real app, you might want to move them to a more permanent location
        
        // Here you could upload to Supabase/Firebase if needed
    }
}

extension DualCameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // We handle both recordings starting in startRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        sessionQueue.async {
            guard let frontURL = self.frontRecordingURL, let backURL = self.backRecordingURL else {
                DispatchQueue.main.async {
                    self.recordingState = .failed(error ?? NSError(domain: "com.dualcam", code: -1, userInfo: nil))
                }
                return
            }
            
            // Wait for both recordings to finish
            if output == self.frontCameraOutput {
                // Front camera finished, check if back also finished
                if let backError = (output == self.backCameraOutput ? error : nil) {
                    DispatchQueue.main.async {
                        self.recordingState = .failed(backError)
                    }
                }
            } else if output == self.backCameraOutput {
                // Back camera finished, check if front also finished
                if let frontError = (output == self.frontCameraOutput ? error : nil) {
                    DispatchQueue.main.async {
                        self.recordingState = .failed(frontError)
                    }
                }
            }
            
            // Both recordings finished successfully
            if FileManager.default.fileExists(atPath: frontURL.path) &&
               FileManager.default.fileExists(atPath: backURL.path) {
                self.saveToCameraRoll(frontURL: frontURL, backURL: backURL)
                DispatchQueue.main.async {
                    self.recordingState = .finished(frontURL: frontURL, backURL: backURL)
                }
            } else {
                DispatchQueue.main.async {
                    self.recordingState = .failed(error ?? NSError(domain: "com.dualcam", code: -2, userInfo: nil))
                }
            }
        }
    }
}
