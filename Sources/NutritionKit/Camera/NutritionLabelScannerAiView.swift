
import Panorama
import SwiftUI
import Toolbox

public struct NutritionLabelScannerAiView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    /// Whether we're currently processing an image.
    @State var isProcessingImage: Bool = false
    
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultLabelCutoutRect
    
    func reset() {
        self.resetCameraCutout()
    }
    
    func resetCameraCutout() {
        withAnimation {
            self.cameraRectangle = DefaultCameraOverlayView.defaultLabelCutoutRect
        }
    }
    
    func onImageCaptured(_ img: UIImage, _ buffer: CVPixelBuffer) {
        image = img
        self.reset()
        presentationMode.wrappedValue.dismiss()
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
