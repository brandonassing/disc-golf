
import SwiftUI

struct RoundView: View {
		
	@StateObject private var viewModel: RoundViewModel
	
	init(scorecard: Scorecard? = nil) {
		self._viewModel = StateObject(wrappedValue: RoundViewModel(scorecard: scorecard))
	}
	
    var body: some View {
		VStack {
			ScorecardView(scorecard: self.viewModel.scorecard)
			
			Spacer()
			
			VStack {
				HStack {
					Text("Par")
				}
				HStack {
					Text("Throws")
				}
				HStack {
					// TODO: add hole name and arrows
				}
			}
		}
	}
}
