
import SwiftUI

extension Color {
	
	// MARK: Convenience initializer for passing in RGB integer values
	init(_ colorSpace: Color.RGBColorSpace = .sRGB, redVal: Double, greenVal: Double, blueVal: Double, opacity: Double = 1) {
		self.init(colorSpace, red: redVal / 255, green: greenVal / 255, blue: blueVal / 255, opacity: opacity)
	}
	
}
