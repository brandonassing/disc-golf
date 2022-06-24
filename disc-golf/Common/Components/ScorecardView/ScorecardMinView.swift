
import SwiftUI

struct ScorecardMinView: View {
	
	@ObservedObject var viewModel: ScorecardViewModel
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(self.viewModel.scorecard.name ?? "No name")
				.font(.headline)
			
			HStack {
				Text(self.viewModel.scorecard.startTime, style: .date)
				
				Text("|")
				
				Text("Score: \(self.viewModel.scorecard.score >= 0 ? "+" : "")\(self.viewModel.scorecard.score)")
					.foregroundColor(.black)

			}
			.foregroundColor(.gray)
		}
	}
}
