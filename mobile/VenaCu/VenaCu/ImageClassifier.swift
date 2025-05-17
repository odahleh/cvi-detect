import SwiftUI
import UIKit
import CoreML
import Vision

struct ClassificationResult {
    let severity: String
    let explainer: String
    let tip: String
    let confidence: Float

    // Add a computed property for color based on severity for the UI circle
    var color: Color {
        switch severity.lowercased() {
        case "normal":
            return .green
        case "moderate":
            return .orange
        case "severe":
            return .red
        default:
            return .gray
        }
    }
}

class ImageClassifier {
    private var model: VNCoreMLModel

    init?() {
        do {
            // Assuming your model class is cvi_model and it's in the bundle
            let coreMLModel = try cvi_model(configuration: MLModelConfiguration()).model
            self.model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Failed to load Core ML model: \(error)")
            return nil
        }
    }

    func classifyImage(imageData: Data, completion: @escaping (ClassificationResult?) -> Void) {
        guard let uiImage = UIImage(data: imageData), let ciImage = CIImage(image: uiImage) else {
            print("Failed to create CIImage from data")
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                print("Vision request failed: \(error)")
                completion(nil)
                return
            }

            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("No classification results or failed to cast results.")
                completion(nil)
                return
            }

            let severity = topResult.identifier
            let confidence = topResult.confidence
            
            // Get explainer and tip based on severity
            let (explainer, tip) = self.getTexts(for: severity)

            let classification = ClassificationResult(severity: severity,
                                                      explainer: explainer,
                                                      tip: tip,
                                                      confidence: confidence)
            completion(classification)
        }

        // Image preprocessing options can be set on the request if needed,
        // e.g., request.imageCropAndScaleOption = .scaleFit
        // However, Core ML models converted with modern tools often handle this.
        // The model from train.py expects 224x224. If the model doesn't handle resize,
        // we might need to resize uiImage or ciImage before creating the request.

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error)")
                completion(nil)
            }
        }
    }

    private func getTexts(for severity: String) -> (explainer: String, tip: String) {
        switch severity.lowercased() {
        case "normal":
            return (explainer: "No significant signs of Chronic Venous Insufficiency (CVI) detected.",
                    tip: "Maintain a healthy lifestyle, engage in regular exercise, and elevate your legs when resting to promote good vein health.")
        case "moderate":
            return (explainer: "Some indicators consistent with moderate Chronic Venous Insufficiency (CVI) are present.",
                    tip: "Consider consulting a healthcare professional for further evaluation. They may recommend lifestyle changes, compression therapy, or other measures.")
        case "severe":
            return (explainer: "Signs consistent with severe Chronic Venous Insufficiency (CVI) are detected.",
                    tip: "It is highly recommended to seek prompt medical consultation for a comprehensive diagnosis and management plan. Do not delay in contacting your doctor.")
        default:
            return (explainer: "Unknown classification.",
                    tip: "Please consult a healthcare professional if you have concerns.")
        }
    }
} 