
import SwiftUI

struct ScorecardView: View {
	
	let scorecard: Scorecard
	
	var body: some View {
		if let name = self.scorecard.name {
			Text(name)
				.padding()
		}
		Text("Total: \(self.scorecard.total >= 0 ? "+" : "")\(self.scorecard.total)")
	}
}
