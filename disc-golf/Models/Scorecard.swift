
struct Scorecard {
	let name: String?
	let holes: [Hole]
}

extension Scorecard {
	var total: Int {
		self.holes.reduce(into: 0, { count, hole in
			count += hole.strokes - hole.par
		})
	}
}

struct Hole {
	let name: String
	let par: Int
	let strokes: Int
}
