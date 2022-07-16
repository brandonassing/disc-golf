
import Foundation
import Combine

class RoundHistoryViewModel: ObservableObject {
	typealias Dependencies = HasCourseRepository
	
	struct Inputs {
		let loadRounds: PassthroughSubject<Void, Never>
		let deleteRound: PassthroughSubject<IndexSet, Never>
	}
	let inputs: Inputs
	
	@Published var scorecards: [Scorecard] = []
	
	private var disposables = Set<AnyCancellable>()
	
	init(dependencies: Dependencies) {
		
		let loadRoundsSubject = PassthroughSubject<Void, Never>()
		let deleteRoundSubject = PassthroughSubject<IndexSet, Never>()
		self.inputs = Inputs(
			loadRounds: loadRoundsSubject,
			deleteRound: deleteRoundSubject
		)
		
		loadRoundsSubject
			.flatMapLatest({
				dependencies.courseRepository.getRounds()
			})
			.receive(on: DispatchQueue.main)
			.assign(to: &self.$scorecards)
		
		deleteRoundSubject
			.map({ [weak self] indexSet -> UUID? in
				guard let self = self, let index = indexSet.first else { return nil }
				return self.scorecards.item(at: index)?.id
			})
			.flatMapLatest({ id -> AnyPublisher<Error?, Never> in
				guard let id = id else {
					return Empty().eraseToAnyPublisher()
				}
				return dependencies.courseRepository.deleteRound(id: id)
			})
			.sink(receiveValue: { [weak self] _ in
				// TODO: only reload on success
				guard let self = self else { return }
				self.inputs.loadRounds.send(())
			})
			.store(in: &self.disposables)
	}
}
