
import SwiftUI

struct RoundHistoryView: View {
	
	@StateObject private var viewModel = RoundHistoryViewModel(dependencies: GlobalDependencyContainer.shared)
	@State private var selectedRound: Scorecard?
	
    var body: some View {
		NavigationView {
			List {
				ForEach(self.viewModel.scorecards) { scorecard in
					ScorecardMinView(viewModel: ScorecardViewModel(scorecard: scorecard))
						.padding(.top)
						.padding(.bottom)
						.onTapGesture {
							self.selectedRound = scorecard
						}
				}
			}
			.onAppear(perform: self.viewModel.inputs.loadRounds.send)
			.overlay {
				if self.viewModel.scorecards.isEmpty {
					VStack {
						Text("No round history")
					}
					.padding()
				}
			}
			.sheet(item: self.$selectedRound) { scorecard in
				VStack {
					ScorecardView(viewModel: ScorecardViewModel(scorecard: scorecard))
						.padding()
					
					Spacer()
				}
			}
			.navigationTitle("Round history")
		}
	}
}
