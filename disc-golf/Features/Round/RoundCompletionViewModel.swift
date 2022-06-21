
import Combine
import Foundation

class RoundCompletionViewModel: ObservableObject {
	
	@Published var scorecard: Scorecard
	
	init(scorecard: Scorecard) {
		
		self.scorecard = Scorecard(
			id: scorecard.id,
			name: scorecard.name,
			holes: scorecard.holes,
			startTime: scorecard.startTime,
			endTime: Date()
		)
	}
}
