# JellyApp

A SwiftUI app with three main tabs: Feed, Camera, and Camera Roll.

## Features

- **Feed Tab**: Displays a TikTok-style video feed with autoplay
- **Camera Tab**: Dual POV camera recording with front and back cameras
- **Camera Roll Tab**: Gallery of recorded videos

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **Combine**: Reactive state management
- **AVFoundation**: For camera and video playback
- **SwiftUI**: Modern declarative UI

## Technical Highlights

1. **Dual Camera Implementation**:
   - Uses `AVCaptureMultiCamSession` for simultaneous recording
   - Handles device orientation and aspect ratios

2. **Feed Performance**:
   - Lazy loading of video items
   - Efficient memory management for video playback

3. **State Management**:
   - Combine for reactive programming
   - Environment objects for shared state

## Snapshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/e976efb8-1b0e-4a42-b303-bbb8c805decb" alt="Feed Tab" width="200"/>
  <img src="https://github.com/user-attachments/assets/bd84f5ba-4b65-4ab8-ab8b-fe1958c110b8" alt="Error scenario" width="200"/>
  <img src="https://github.com/user-attachments/assets/98a79c88-d471-4d7c-9fd2-a1866e2b9a53" alt="Camera Tab" width="200"/>
  <img src="https://github.com/user-attachments/assets/568172a2-54fe-49d1-91e2-64490ab202f7" alt="Camera Roll Tab" width="200"/>
</p>

## Tradeoffs

1. **Video Processing**:
   - Currently saves raw videos without processing
   - In a production app, would implement video composition

2. **Persistence**:
   - Uses in-memory storage for simplicity
   - Would implement CoreData or similar in production

3. **Error Handling**:
   - Basic error handling implemented
   - Would expand with user-friendly messages in production

## Setup

1. Clone the repository
2. Open `JellyApp.xcodeproj`
3. Build and run on a physical device (camera features require real device)

## Future Improvements

1. Implement proper video composition for dual recordings
2. Add cloud storage integration
3. Enhance feed with real API integration
4. Add user authentication
5. Implement more sophisticated video caching
