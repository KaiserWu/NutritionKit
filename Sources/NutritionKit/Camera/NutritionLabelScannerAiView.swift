
import Panorama
import SwiftUI
import Toolbox

public struct NutritionLabelScannerAiView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultLabelCutoutRect
    
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
