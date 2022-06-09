
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

struct Hole: Identifiable {
	let id = UUID()
	let name: String
	let par: Int
	let strokes: Int?
}
