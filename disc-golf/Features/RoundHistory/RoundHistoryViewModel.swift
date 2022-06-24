
import Foundation
import Combine

class RoundHistoryViewModel: ObservableObject {
	typealias Dependencies = HasCourseRepository
	
	struct Inputs {
		let loadRounds: PassthroughSubject<Void, Never>
	}
	let inputs: Inputs
	
	@Published var scorecards: [Scorecard] = []
	
	init(dependencies: Dependencies) {
		
		let loadRoundsSubject = PassthroughSubject<Void, Never>()
		self.inputs = Inputs(
			loadRounds: loadRoundsSubject
		)
		
		loadRoundsSubject
			.flatMapLatest({
				dependencies.courseRepository.getRounds()
			})
			.receive(on: DispatchQueue.main)
			.assign(to: &self.$scorecards)
	}
}
