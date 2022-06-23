
import Combine
import Foundation

class RoundCompletionViewModel: ObservableObject {
	
	@Published var scorecard: Scorecard
	@Published var needsName: Bool = true
	@Published var courseName: String = ""
	
	init(scorecard: Scorecard) {
		
		self.scorecard = Scorecard(
			id: scorecard.id,
			name: scorecard.name,
			holes: scorecard.holes,
			startTime: scorecard.startTime,
			endTime: Date()
		)
		
		self.$scorecard
			.map({ $0.name == nil })
			.assign(to: &self.$needsName)
		
		self.$courseName
			.filter({ !$0.isEmpty })
			.map({ Scorecard(id: self.scorecard.id, name: $0, holes: self.scorecard.holes, startTime: self.scorecard.startTime, endTime: self.scorecard.endTime) })
			.assign(to: &self.$scorecard)
	}
}
