
import Combine
import Foundation

class ScorecardViewModel: ObservableObject {
	
	@Published var scorecard: Scorecard
	@Published var cells: [Cell]
	
	enum Cell {
		case label(id: UUID = UUID())
		case holeInfo(Hole)
	}
	
	init(scorecard: Scorecard) {
		self.scorecard = scorecard
		
		self.cells = scorecard.holes.enumerated().reduce(into: [Cell](), { cells, holeInfo in
			if holeInfo.offset % 9 == 0 {
				cells.append(.label())
			}
			cells.append(.holeInfo(holeInfo.element))
		})
	}
}

extension ScorecardViewModel.Cell: Identifiable {
	var id: UUID {
		switch self {
		case .label(let id):
			return id
		case .holeInfo(let hole):
			return hole.id
		}
	}
}
