
import Foundation
import Combine

protocol CourseRepository {
	func saveRound(scorecard: Scorecard) -> AnyPublisher<Error?, Never>
}

class ApplicationCourseRepository: CourseRepository {
	typealias Dependencies = HasFileManagerService
	
	func saveRound(scorecard: Scorecard) -> AnyPublisher<Error?, Never> {
		guard let url = self.fileManagerService.cacheUrl?.appendingPathComponent("rounds.json") else {
			return Just(GenericError.badUrl)
				.eraseToAnyPublisher()
		}
		
		var rounds: [Scorecard] = []
		if let roundsData = self.fileManagerService.read(from: url) {
			guard let roundsFromData = try? JSONDecoder().decode([Scorecard].self, from: roundsData) else {
				return Just(GenericError.decoding)
					.eraseToAnyPublisher()
			}
			rounds = roundsFromData
		}
		
		rounds.append(scorecard)
		
		guard let newRoundsData = try? JSONEncoder().encode(rounds) else {
			return Just(GenericError.encoding)
				.eraseToAnyPublisher()
		}
		
		self.fileManagerService.write(newRoundsData, to: url)
		
		return Just(nil)
			.eraseToAnyPublisher()
	}
	
	private let fileManagerService: FileManagerService
	
	init(dependencies: Dependencies) {
		self.fileManagerService = dependencies.fileManagerService
	}
}
