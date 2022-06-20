
import SwiftUI

struct RoundCompletionView: View {

	let scorecard: Scorecard
	let dismiss: () -> ()
		
    var body: some View {
		VStack(spacing: 50) {
			ScorecardView(viewModel: ScorecardViewModel(scorecard: self.scorecard))
				.padding()

			Button(action: { self.dismiss() }) {
				Text("Finish")
			}
			.buttonStyle(.bordered)
			
			Spacer()
		}
    }
}
