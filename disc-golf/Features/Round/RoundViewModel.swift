
import Combine

class RoundViewModel: ObservableObject {
	
	private static let defaultPar = 3
	
	@Published var scorecard: Scorecard
	@Published var currentHole: Hole = Hole(name: "1", par: RoundViewModel.defaultPar, strokes: nil)
	
	init(scorecard: Scorecard?) {
		if let scorecard = scorecard {
			self.scorecard = scorecard
		} else {
			self.scorecard = Scorecard(name: nil, holes: [
				Hole(name: "1", par: 3, strokes: 3), Hole(name: "2", par: 4, strokes: 3), Hole(name: "3", par: 3, strokes: 4),
				Hole(name: "4", par: 3, strokes: 3), Hole(name: "5", par: 3, strokes: 3), Hole(name: "6L", par: 3, strokes: 5),
				Hole(name: "7", par: 5, strokes: 4), Hole(name: "8", par: 4, strokes: 4), Hole(name: "9", par: 4, strokes: 4),
				Hole(name: "10", par: 3, strokes: 3), Hole(name: "11", par: 4, strokes: 5), Hole(name: "12", par: 4, strokes: nil),
			])
//			self.scorecard = Scorecard(name: nil, holes: [self.currentHole]) // TODO: want to add first hole to default scorecard
		}
	}
}
