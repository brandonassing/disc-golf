
import Combine

class RoundViewModel: ObservableObject {
	
	@Published var scorecard: Scorecard
	
	init(scorecard: Scorecard?) {
		if let scorecard = scorecard {
			self.scorecard = scorecard
		} else {
			self.scorecard = Scorecard(name: nil, holes: [])
		}
	}
}
