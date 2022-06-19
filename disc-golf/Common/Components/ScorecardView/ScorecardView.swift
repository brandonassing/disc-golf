
import SwiftUI

struct ScorecardView: View {
	
	@ObservedObject var viewModel: ScorecardViewModel
		
	private let columns: [GridItem] = ScorecardViewModel.Cell.labelGridItems + ScorecardViewModel.Cell.holeGridItems
	
	var body: some View {
		VStack {
			if let name = self.viewModel.scorecard.name {
				Text(name)
					.padding()
			}
			Text("Total: \(self.viewModel.scorecard.total >= 0 ? "+" : "")\(self.viewModel.scorecard.total)")
			
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
