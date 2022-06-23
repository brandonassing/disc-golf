
import Foundation

struct Scorecard: Codable {
	let id: UUID
	let name: String?
	let holes: [Hole]
	let startTime: Date
	let endTime: Date?
}

extension Scorecard {
	var par: Int {
		self.holes.reduce(into: 0, { count, hole in
			count += hole.par
		})
	}
	
	var strokes: Int {
		return self.par + self.score
	}
	
	var score: Int {
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

struct Hole: Identifiable, Equatable, Codable {
	let id: UUID
	let name: String
	let par: Int
	let strokes: Int?
}
