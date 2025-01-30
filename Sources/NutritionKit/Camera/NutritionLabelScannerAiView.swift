
import Panorama
import SwiftUI
import Toolbox

public struct NutritionLabelScannerAiView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultLabelCutoutRect
    @State var isProcessingImage: Bool = false
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    func reset() {
        self.resetCameraCutout()
    }
    
    func resetCameraCutout() {
        withAnimation {
            self.cameraRectangle = DefaultCameraOverlayView.defaultLabelCutoutRect
        }
    }
    
    func onImageCaptured(_ img: UIImage, _ buffer: CVPixelBuffer) {
        guard let cgImage = img.cgImage else {
            self.reset()
            return
        }
        
        self.isProcessingImage = true
        
        // TODO: Add blur detection
        Task {
            await self.processCapturedImage(cgImage)
        }
    }
    
    func processCapturedImage(_ image: CGImage) async {
        let scanner = NutritionLabelDetector(image: image)
        do {
            guard let (_, rect) = try await scanner.findNutritionLabel() else {
                DispatchQueue.main.async {
                    self.reset()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.cameraRectangle = .init(rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight)
                }
            }
            
            let label = try await scanner.scanNutritionLabel()
            guard label.isValid else {
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isProcessingImage = false
                self.image = UIImage(cgImage: image)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        catch {
            Log.nutritionKit.error("finding nutrition label failed: \(error.localizedDescription)")
        }
    }
    
    public var body: some View {
        ZStack {
            AnyCameraView(onImageUpdated: { img, buffer in
                self.onImageCaptured(img, buffer)
            }) {
                DefaultCameraOverlayView(rectangle: $cameraRectangle)
            }
        }
    }
}
