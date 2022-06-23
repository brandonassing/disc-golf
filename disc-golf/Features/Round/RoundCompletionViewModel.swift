
import Foundation
import Combine
import CombineExt

class RoundCompletionViewModel: ObservableObject {
	
	typealias Dependencies = HasCourseRepository
	
	struct Inputs {
		let saveRound: PassthroughSubject<Void, Never>
	}
	
	let inputs: Inputs
	
	@Published var scorecard: Scorecard
	@Published var needsName: Bool = true
	@Published var courseName: String = ""
	@Published var saveRoundSuccess: Void = ()
		
	private var disposables = Set<AnyCancellable>()
	
	init(scorecard: Scorecard, dependencies: Dependencies) {
		
		let saveRoundSubject = PassthroughSubject<Void, Never>()
		self.inputs = Inputs(
			saveRound: saveRoundSubject
		)
				
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
		
		let saveRequest = saveRoundSubject
			.withLatestFrom(self.$scorecard)
			.flatMapLatest({
				dependencies.courseRepository.saveRound(scorecard: $0)
			})
			.receive(on: DispatchQueue.main)
		
		self.saveRoundSuccess = saveRequest
			.filter({ $0 == nil })
			.sink(receiveValue: { _ in
				self.saveRoundSuccess = ()
			})
			.store(in: &self.disposables)

	}
}
