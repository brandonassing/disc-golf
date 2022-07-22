
import SwiftUI

struct ScorecardHoleCellView: View {
	let hole: Hole
	let isCurrent: Bool?
	
    var body: some View {
		VStack {
			Text("\(self.hole.name)")
				.foregroundColor((self.isCurrent ?? false) ? .green : .gray)
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
		.frame(width: 30)
    }
}
