
import SwiftUI

enum StyleGuide {
	enum Colour {}
}

extension StyleGuide.Colour {
	static func selected(forColorScheme scheme: ColorScheme) -> Color {
		switch scheme {
		case .light:
			return Color(redVal: 228, greenVal: 217, blueVal: 252)
		case .dark:
			return Color(redVal: 58, greenVal: 12, blueVal: 163)
 		@unknown default:
			return Color.clear
		}
	}
}
