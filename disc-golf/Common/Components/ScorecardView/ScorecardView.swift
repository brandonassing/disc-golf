
import SwiftUI

struct ScorecardView: View {
	
	@ObservedObject var viewModel: ScorecardViewModel
		
	private let columns: [GridItem] = ScorecardViewModel.Cell.labelGridItems + ScorecardViewModel.Cell.holeGridItems
	
	var body: some View {
		VStack {
			if let name = self.viewModel.scorecard.name {
				Text(name)
					.padding()
					.font(.headline)
			}
			
			VStack {
				if self.viewModel.scorecard.endTime != nil {
					Text(self.viewModel.scorecard.startTime, style: .date)
					
					HStack {
						Text("Round start:")
						Text(self.viewModel.scorecard.startTime, style: .time)
					}

					HStack {
						Text("Time elapsed:")
						Text("\(self.viewModel.minutesElapsed) mins")
					}
				} else {
					HStack {
						Text("Round start:")
						Text(self.viewModel.scorecard.startTime, style: .time)
					}
				}
			}
			.foregroundColor(.gray)

			HStack {
				Spacer()
				VStack(alignment: .trailing) {
					Text("Par: \(self.viewModel.scorecard.par)")
					Text("Strokes: \(self.viewModel.scorecard.strokes)")
				}
				.foregroundColor(.gray)
			}
			
			Text("Score: \(self.viewModel.scorecard.score >= 0 ? "+" : "")\(self.viewModel.scorecard.score)")
			
			LazyVGrid(columns: self.columns, alignment: .leading, spacing: 30) {
				ForEach(self.viewModel.cells) { cell in
					switch cell {
					case .label:
						ScorecardLabelCellView()
					case .holeInfo(let hole):
						ScorecardHoleCellView(hole: hole)
					}
				}
			}
		}
	}
}

extension ScorecardViewModel.Cell {
	// TODO: find better way to link GridItems to enum cases
	static let labelGridItems = [GridItem(.fixed(60), spacing: 20)]
	static let holeGridItems = [
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
		GridItem(.flexible()),
	]
}
