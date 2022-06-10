
import Combine

class RoundViewModel: ObservableObject {
	
	static let defaultPar = ParOption.three
	static let defaultHoleName = "1"
	
	struct Inputs {
		let par: CurrentValueSubject<Int, Never>
		let holeName: CurrentValueSubject<String, Never>
		let previousHole: PassthroughSubject<Void, Never>
		let nextHole: PassthroughSubject<Void, Never>
	}
	
	let inputs: Inputs
	
	@Published var scorecard: Scorecard
	@Published var currentHole: Hole
	
	private var disposables = Set<AnyCancellable>()
	
	init(scorecard: Scorecard?) {
		
		var defaultHole = Hole(name: RoundViewModel.defaultHoleName, par: RoundViewModel.defaultPar.rawValue, strokes: nil)
		if let scorecard = scorecard, !scorecard.holes.isEmpty {
			self.scorecard = scorecard
			if let firstHole = scorecard.holes.first {
				defaultHole = firstHole
			}
		} else {
			self.scorecard = Scorecard(name: nil, holes: [defaultHole])
//			self.scorecard = Scorecard(name: nil, holes: [
//				Hole(name: "1", par: 3, strokes: 3), Hole(name: "2", par: 4, strokes: 3), Hole(name: "3", par: 3, strokes: 4),
//				Hole(name: "4", par: 3, strokes: 3), Hole(name: "5", par: 3, strokes: 3), Hole(name: "6L", par: 3, strokes: 5),
//				Hole(name: "7", par: 5, strokes: 4), Hole(name: "8", par: 4, strokes: 4), Hole(name: "9", par: 4, strokes: 4),
//				Hole(name: "10", par: 3, strokes: 3), Hole(name: "11", par: 4, strokes: 5), Hole(name: "12", par: 4, strokes: nil),
//			])
		}

		self.currentHole = defaultHole
		
		let parSubject = CurrentValueSubject<Int, Never>(defaultHole.par)
		let holeNameSubject = CurrentValueSubject<String, Never>(defaultHole.name)
		let previousHoleSubject = PassthroughSubject<Void, Never>()
		let nextHoleSubject = PassthroughSubject<Void, Never>()
		self.inputs = Inputs(
			par: parSubject,
			holeName: holeNameSubject,
			previousHole: previousHoleSubject,
			nextHole: nextHoleSubject
		)
				
		Publishers.CombineLatest(parSubject, holeNameSubject)
			.map({ par, holeName in
				Hole(name: holeName, par: par, strokes: nil)
			})
			.assign(to: &self.$currentHole)
		
	}
	
	enum ParOption: Int, CaseIterable {
		case two = 2
		case three = 3
		case four = 4
		case five = 5
		case six = 6
	}
}
