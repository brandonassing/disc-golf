
import Combine
import Foundation

class ScorecardViewModel: ObservableObject {
	
	struct Inputs {
		let scorecardSubject: CurrentValueSubject<Scorecard, Never>
	}
	
	let inputs: Inputs
	
	@Published var scorecard: Scorecard = Scorecard(name: nil, holes: [])
	@Published var cells: [Cell] = []
	
	enum Cell {
		case label(id: UUID = UUID())
		case holeInfo(Hole)
	}
	
	init(scorecard: Scorecard) {
		
		let scorecardSubject = CurrentValueSubject<Scorecard, Never>(scorecard)
		self.inputs = Inputs(
			scorecardSubject: scorecardSubject
		)
				
		scorecardSubject
			.removeDuplicates()
			.assign(to: &self.$scorecard)
		
		self.$scorecard
			.map({ scorecard in
				scorecard.holes.enumerated().reduce(into: [Cell](), { cells, holeInfo in
					if holeInfo.offset % 9 == 0 {
						cells.append(.label())
					}
					cells.append(.holeInfo(holeInfo.element))
				})
			})
			.assign(to: &self.$cells)
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
