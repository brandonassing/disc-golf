
import SwiftUI

struct RoundCompletionView: View {
	
	let scorecard: Scorecard
	
    var body: some View {
		VStack(spacing: 50) {
			ScorecardView(viewModel: ScorecardViewModel(scorecard: self.scorecard))
				.padding()

			Button(action: {}) {
				Text("Finish")
			}
			.buttonStyle(.bordered)
			
			Spacer()
		}
    }
}
