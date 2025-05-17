import SwiftUI
import AVFoundation
// UIKit should be available if project is configured correctly
#if canImport(UIKit)
import UIKit
#endif

// UIViewRepresentable to show camera preview
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

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// ViewModel for Camera
class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: CameraPreview?
    @Published var isTaken = false
    @Published var picData = Data(count: 0)
    
    // Properties for classification results
    @Published var classificationResult: ClassificationResult? = nil
    @Published var isProcessing = false // To show a loading indicator during classification

    private var imageClassifier: ImageClassifier?

    override init() {
        super.init()
        self.imageClassifier = ImageClassifier() // Initialize the classifier
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    DispatchQueue.main.async {
                        self.setUp()
                    }
                }
            }
        case .denied:
            print("Camera permission denied")
            // TODO: Show an alert to the user guiding them to settings
            return
        default:
            return
        }
    }

    func setUp() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No back camera found")
                self.session.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            } catch {
                print("Error setting up camera input: \(error.localizedDescription)")
                self.session.commitConfiguration()
                return
            }

            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()

            DispatchQueue.main.async {
                self.preview = CameraPreview(session: self.session)
            }
        }
    }

    func takePic(){
        DispatchQueue.main.async {
            self.isProcessing = true // Start processing indicator
        }
        DispatchQueue.global(qos: .userInitiated).async { // Changed from .background for potentially faster processing
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Could not get image data representation")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }
        
        // Stop the session and set picData on the main thread before classification
        DispatchQueue.main.async {
            self.picData = imageData
            self.isTaken = true
            self.session.stopRunning()
            print("Photo captured, data size: \(self.picData.count). Ready for model processing.")
            
            // Now classify the image
            self.classifyTakenImage()
        }
    }

    private func classifyTakenImage() {
        guard picData.count > 0, let classifier = imageClassifier else {
            print("No image data to classify or classifier not available")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }

        classifier.classifyImage(imageData: picData) { [weak self] result in
            DispatchQueue.main.async {
                self?.classificationResult = result
                self?.isProcessing = false
                if result == nil {
                    print("Classification returned no result.")
                    // Optionally, show an error to the user
                }
            }
        }
    }
    
    func reTake(){
        DispatchQueue.main.async {
            self.isTaken = false
            self.picData = Data(count: 0)
            self.classificationResult = nil
            self.isProcessing = false // Reset processing state
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
}

struct CameraView: View {
    @StateObject var camera = CameraViewModel()

    var body: some View {
        ZStack {
            if let preview = camera.preview {
                preview
                    .ignoresSafeArea(.all, edges: .all)
            } else {
                Color.black // Show black background if preview is not yet available
                    .ignoresSafeArea(.all, edges: .all)
                ProgressView() // Show a loading indicator
            }

            VStack {
                Spacer() // Pushes button to the bottom
                Button(action: {
                    if camera.isTaken {
                        camera.reTake()
                    } else {
                        camera.takePic()
                    }
                }) {
                    ZStack{
                        Circle()
                            .fill(camera.isTaken ? Color.yellow : Color.white)
                            .frame(width: 80, height: 80)
                        
                        if camera.isTaken{
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                                .frame(width: 70, height: 70)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear(perform: {
            camera.checkPermissions()
        })
        // Handle changes if photo is taken, e.g., to pass to a new view or process with ML model
        .onChange(of: camera.isTaken) { newValue in
            if newValue {
                // Photo has been taken, self.camera.picData is available
                // You can navigate to a new view or trigger model processing here
                print("Photo is taken, ready for next step.")
            }
        }
    }
}

#Preview {
    CameraView()
} 