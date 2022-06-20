
import SwiftUI

struct RoundCompletionView: View {

	@StateObject private var viewModel: RoundCompletionViewModel
	private let dismiss: () -> ()

	init(scorecard: Scorecard, dismiss: @escaping () -> ()) {
		self._viewModel = StateObject(wrappedValue: RoundCompletionViewModel(scorecard: scorecard))
		self.dismiss = dismiss
	}
	
    var body: some View {
		VStack(spacing: 50) {
			ScorecardView(viewModel: ScorecardViewModel(scorecard: self.viewModel.scorecard))
				.padding()

			Button(action: { self.dismiss() }) {
				Text("Finish")
			}
			.buttonStyle(.bordered)
			
			Spacer()
		}
    }
}
