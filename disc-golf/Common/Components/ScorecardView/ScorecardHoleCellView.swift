
import SwiftUI

struct ScorecardHoleCellView: View {
	@Environment(\.colorScheme) private var colorScheme

	let hole: Hole
	let isCurrent: Bool?
	
    var body: some View {
		VStack {
			Text("\(self.hole.name)")
				.foregroundColor(.secondary)
				.lineLimit(1)
			Text("\(self.hole.par)")
			
			if let strokes = self.hole.strokes {
				let scoreColour = strokes == self.hole.par ? Color.primary : (strokes > self.hole.par ? Color.red : Color.blue)
				Text("\(strokes)")
					.foregroundColor(scoreColour)
			} else {
				Text("-")
			}
		}
		.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
		.frame(width: 30)
		.background((self.isCurrent ?? false) ? StyleGuide.Colour.selected(forColorScheme: self.colorScheme) : .clear)
		.cornerRadius(8)
    }
}
