//
//  DualCameraView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//


import SwiftUI
import AVKit
import Combine

struct CameraTabView: View {
    @StateObject private var cameraManager = DualCameraManager()
    @State private var showPreview = false
    @State private var recordedURLs: (URL, URL)?
    @State private var displayCameraUsageAlert: Bool = false

    var body: some View {
        ZStack {
            if !showPreview {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        CameraPreviewView(layer: cameraManager.previewLayerFront)
                            .frame(height: geometry.size.height / 2)
                            .background(Color.black)

                        CameraPreviewView(layer: cameraManager.previewLayerBack)
                            .frame(height: geometry.size.height / 2)
                            .background(Color.black)
                    }
                    .edgesIgnoringSafeArea(.all)
                }

                VStack {
                    if cameraManager.isRecording {
                            Text(timeString(from: cameraManager.recordingDuration))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.6))
                                        .overlay(
                                            Capsule().stroke(Color.red, lineWidth: 2)
                                        )
                                )
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.4), radius: 8, x: 0, y: 2)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.3), value: cameraManager.recordingDuration)
                        }

                    Spacer()
                    RecordButton(isRecording: $cameraManager.isRecording) {
                        if cameraManager.isRecording {
                            cameraManager.stopRecordingManually()
                        } else {
                            cameraManager.startRecordingWithTimer()
                        }
                    }
                    .padding(.bottom, 40)
                }
                .animation(.easeInOut, value: cameraManager.isRecording)
            } else if let urls = recordedURLs {
                PreviewView(frontCameraURL: urls.0, backCameraURL: urls.1)
            }
        }
        .onAppear {
            cameraManager.checkPermissions()
            displayCameraUsageAlert = true

            cameraManager.recordingFinishedHandler = { front, back in
                recordedURLs = (front, back)
                //showPreview = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    NotificationCenter.default.post(name: .navigateToTab3, object: nil)
                }
            }
        }
        .onDisappear {
            cameraManager.stopRecordingManually()
        }
        .onReceive(NotificationCenter.default.publisher(for: .startRecordingFromTabSwitch)) { _ in
            cameraManager.startRecordingWithTimer()
        }
        .alert("Camera Usage", isPresented: $displayCameraUsageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This app needs access to your camera to record videos.")
        }
    }

    func timeString(from seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}


// Camera Preview UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    var layer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> UIView {
        let view = PreviewContainerView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewContainer = uiView as? PreviewContainerView else { return }
        
        // Remove old and add new layer
        if let newLayer = layer {
            previewContainer.setPreviewLayer(newLayer)
        }
    }

    class PreviewContainerView: UIView {
        private var currentLayer: AVCaptureVideoPreviewLayer?

        func setPreviewLayer(_ newLayer: AVCaptureVideoPreviewLayer) {
            // Remove previous
            currentLayer?.removeFromSuperlayer()
            currentLayer = newLayer
            newLayer.frame = bounds
            layer.addSublayer(newLayer)
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            currentLayer?.frame = bounds
        }
    }
}



// Record Button View
struct RecordButton: View {
    @Binding var isRecording: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: 6)
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
                Circle()
                    .frame(width: 58, height: 58)
                    .foregroundColor(isRecording ? .red : .white)
            }
        }
    }
}
