
import SwiftUI

struct RoundCompletionView: View {

	@StateObject private var viewModel: RoundCompletionViewModel
	@State private var isActive = false
	private let dismiss: () -> ()
	

	init(scorecard: Scorecard, dismiss: @escaping () -> ()) {
		self._viewModel = StateObject(wrappedValue: RoundCompletionViewModel(scorecard: scorecard, dependencies: GlobalDependencyContainer.shared))
		self.dismiss = dismiss
	}
	
    var body: some View {
		VStack(spacing: 50) {
			ScorecardView(viewModel: ScorecardViewModel(scorecard: self.viewModel.scorecard))
				.padding()

			Button(action: {
				if !self.viewModel.needsName {
					self.viewModel.inputs.saveRound.send()
					return
				}
				self.isActive = self.viewModel.needsName
			}) {
				Text("Finish")
			}
			.buttonStyle(.bordered)
			.sheet(isPresented: self.$isActive) {
				RoundNameView { name in
					self.viewModel.courseName = name
				}
			}

			Spacer()
		}
		.onReceive(self.viewModel.$saveRoundSuccess.dropFirst(), perform: {
			self.dismiss()
		})

    }
}
