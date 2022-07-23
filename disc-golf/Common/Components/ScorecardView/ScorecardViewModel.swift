
import Combine
import Foundation

class ScorecardViewModel: ObservableObject {
		
	@Published var scorecard: Scorecard
	@Published var cells: [Cell] = []
	@Published var minutesElapsed: Int = 0

	enum Cell {
		case label(id: UUID = UUID())
		case holeInfo(Hole, isCurrent: Bool?)
	}
	
	init(scorecard: Scorecard, currentHole: Hole? = nil) {
		self.scorecard = scorecard
		
		self.$scorecard
			.removeDuplicates()
			.map({ scorecard in
				scorecard.holes.enumerated().reduce(into: [Cell](), { cells, holeInfo in
					if holeInfo.offset % 9 == 0 {
						cells.append(.label())
					}
					cells.append(.holeInfo(holeInfo.element, isCurrent: holeInfo.element.id == currentHole?.id))
				})
			})
			.assign(to: &self.$cells)
		
		self.$scorecard
			.map({ scorecard in
				guard let endTime = scorecard.endTime else {
					return 0
				}
				let diffComponents = Calendar.current.dateComponents([.minute], from: scorecard.startTime, to: endTime)

				return diffComponents.minute ?? 0
			})
			.assign(to: &self.$minutesElapsed)
	}
}

extension ScorecardViewModel.Cell: Identifiable {
	var id: UUID {
		switch self {
		case .label(let id):
			return id
		case .holeInfo(let hole, _):
			return hole.id
		}
	}
}
