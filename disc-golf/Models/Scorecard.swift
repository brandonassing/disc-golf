
import Foundation

struct Scorecard {
	let name: String?
	let holes: [Hole]
}

extension Scorecard {
	var total: Int {
		self.holes.reduce(into: 0, { count, hole in
			guard let strokes = hole.strokes else { return }
			count += strokes - hole.par
		})
	}
}

extension Scorecard: Equatable {
	static func == (lhs: Scorecard, rhs: Scorecard) -> Bool {
		lhs.name == rhs.name && lhs.holes == rhs.holes
	}
}

struct Hole: Identifiable, Equatable {
	let id: UUID
	let name: String
	let par: Int
	let strokes: Int?
}
