
import SwiftUI

struct ScorecardHoleCellView: View {
	let hole: Hole
	
    var body: some View {
		VStack {
			Text("\(self.hole.name)")
				.foregroundColor(.gray)
				.lineLimit(1)
			Text("\(self.hole.par)")
			
			if let strokes = self.hole.strokes {
				Text("\(strokes)")
			} else {
				Text("-")
			}
		}
		.frame(width: 20)
    }
}
