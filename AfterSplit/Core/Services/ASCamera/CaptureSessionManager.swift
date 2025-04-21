////
////  CaptureSessionManager.swift
////  AfterSplit
////
////  Created by Kehinde Akeredolu on 20/04/2025.
////
//
//import AVFoundation
//import Combine
//
//class CaptureSessionManager: NSObject, ObservableObject ,AVCapturePhotoCaptureDelegate{
//    @Published var session: AVCaptureMultiCamSession?
//    private var frontCameraInput: AVCaptureDeviceInput?
//    private var rearCameraInput: AVCaptureDeviceInput?
//    // Add photo and movie file output properties later
//    // Add delegate properties later
//   
//    private var frontPhotoOutput: AVCapturePhotoOutput?
//    private var rearPhotoOutput: AVCapturePhotoOutput?
//  
//    private var frontMovieOutput: AVCaptureMovieFileOutput?
//    private var rearMovieOutput: AVCaptureMovieFileOutput?
//
//
//    override init() {
//        super.init()
//        setupSession()
//    }
//
//    private func setupSession() {
//        session = AVCaptureMultiCamSession()
//        session?.beginConfiguration()
//
//        // Discover and configure devices
//        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//              let rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            // Handle scenario where cameras are not available
//            session?.commitConfiguration()
//            return
//        }
//
//        do {
//            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
//            rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
//
//            if let frontInput = frontCameraInput, session?.canAddInput(frontInput) ?? false {
//                session?.addInputWithNoConnections(frontInput)
//            }
//            if let rearInput = rearCameraInput, session?.canAddInput(rearInput) ?? false {
//                session?.addInputWithNoConnections(rearInput)
//            }
//
//            // Configure outputs and connections here
//            // ...
//
//        } catch {
//            print("Error setting up camera inputs: \(error.localizedDescription)")
//        }
//
//        session?.commitConfiguration()
//    }
//
//    func startSession() {
//        // Ensure session is not nil and not running before starting
//         if let currentSession = session, !currentSession.isRunning {
//               // Check hardwareCost before starting session
//               if currentSession.hardwareCost <= 1.0 {
//                   currentSession.startRunning()
//               } else {
//                   print("Hardware cost too high: \(currentSession.hardwareCost). Cannot start session.")
//                   // Handle the case where hardware cost is too high
//               }
//           }
//    }
//
//    func stopSession() {
//        session?.stopRunning()
//    }
//    
//  
//
//    func configurePhotoOutput() {
//        frontPhotoOutput = AVCapturePhotoOutput()
//        rearPhotoOutput = AVCapturePhotoOutput()
//
//        if let frontOutput = frontPhotoOutput, session?.canAddOutput(frontOutput) ?? false {
//            session?.addOutputWithNoConnections(frontOutput)
//            // Establish connection
//            if let input = frontCameraInput,
//         
//             let   connection = AVCaptureConnection(inputPorts: input.ports, output: frontOutput) {
//                session?.addConnection(connection)
//            }
//        }
//        if let rearOutput = rearPhotoOutput, session?.canAddOutput(rearOutput) ?? false {
//            session?.addOutputWithNoConnections(rearOutput)
//             // Establish connection
//            if let input = rearCameraInput,
//               let connection = AVCaptureConnection(inputPorts: input.ports, output: rearOutput) {
//                session?.addConnection(connection)
//            }
//        }
//    }
//
//    func capturePhoto() {
//        guard let frontOutput = frontPhotoOutput, let rearOutput = rearPhotoOutput else { return }
//
//        let settings = AVCapturePhotoSettings()
//        // Configure settings like flash mode, format, etc.
//
//        let frontDelegate = PhotoCaptureDelegate() // Implement this class
//        let rearDelegate = PhotoCaptureDelegate() // Implement this class
//
//        frontOutput.capturePhoto(with: settings, delegate: frontDelegate)
//        rearOutput.capturePhoto(with: settings, delegate: rearDelegate)
//
//        // The delegate methods will receive the captured photo data
//    }
//
//    // Implement PhotoCaptureDelegate class separately to handle photo data and combination.
//    // This class will need to store the captured images from both cameras and combine them
//    // once both are available.
//  
//    func configureMovieOutput() {
//        frontMovieOutput = AVCaptureMovieFileOutput()
//        rearMovieOutput = AVCaptureMovieFileOutput()
//
//        if let frontOutput = frontMovieOutput, session?.canAddOutput(frontOutput) ?? false {
//            session?.addOutputWithNoConnections(frontOutput)
//             // Establish connection
//            if let input = frontCameraInput,
//               let connection = AVCaptureConnection(inputPorts: input.ports, output: frontOutput) {
//                session?.addConnection(connection)
//            }
//        }
//        if let rearOutput = rearMovieOutput, session?.canAddOutput(rearOutput) ?? false {
//            session?.addOutputWithNoConnections(rearOutput)
//             // Establish connection
//            if let input = rearCameraInput,
//               let connection = AVCaptureConnection(inputPorts: input.ports, output: rearOutput) {
//                session?.addConnection(connection)
//            }
//        }
//    }
//
//    func startRecording() {
//        guard let frontOutput = frontMovieOutput, let rearOutput = rearMovieOutput else { return }
//
//        let frontOutputFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
//        let rearOutputFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
//
//        let recordingDelegate = MovieFileOutputRecordingDelegate() // Implement this class
//
//        frontOutput.startRecording(to: frontOutputFileUrl, recordingDelegate: recordingDelegate)
//        rearOutput.startRecording(to: rearOutputFileUrl, recordingDelegate: recordingDelegate)
//    }
//
//    func stopRecording() {
//        frontMovieOutput?.stopRecording()
//        rearMovieOutput?.stopRecording()
//    }
//
//    // Implement MovieFileOutputRecordingDelegate class separately to handle recording events
//    // and move the temporary files to a permanent storage location upon completion.
//}
