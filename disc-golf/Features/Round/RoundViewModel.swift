
import Combine
import Foundation

class RoundViewModel: ObservableObject {
	
	static let defaultPar = ParOption.three
	static let defaultHoleName = "1"
	
	struct Inputs {
		let decreaseStrokes: PassthroughSubject<Void, Never>
		let increaseStrokes: PassthroughSubject<Void, Never>
		let holeName: CurrentValueSubject<String, Never>
		let previousHole: PassthroughSubject<Void, Never>
		let nextHole: PassthroughSubject<Void, Never>
	}
	
	let inputs: Inputs
	
	@Published var parOption: ParOption = RoundViewModel.defaultPar
	@Published var strokes: Int?
	
	@Published var currentHole: Hole
	@Published var scorecard: Scorecard

	private var disposables = Set<AnyCancellable>()
	
	init(scorecard: Scorecard?) {
		
		var startingHole = Hole(name: RoundViewModel.defaultHoleName, par: RoundViewModel.defaultPar.rawValue, strokes: nil)
		
		if let scorecard = scorecard, !scorecard.holes.isEmpty {
			self.scorecard = scorecard
			if let firstHole = scorecard.holes.first, let parOption = ParOption(rawValue: firstHole.par) {
				startingHole = firstHole
				self.parOption = parOption
			}
		} else {
			self.scorecard = Scorecard(name: nil, holes: [startingHole])
//			self.scorecard = Scorecard(name: nil, holes: [
//				Hole(name: "1", par: 3, strokes: 3), Hole(name: "2", par: 4, strokes: 3), Hole(name: "3", par: 3, strokes: 4),
//				Hole(name: "4", par: 3, strokes: 3), Hole(name: "5", par: 3, strokes: 3), Hole(name: "6L", par: 3, strokes: 5),
//				Hole(name: "7", par: 5, strokes: 4), Hole(name: "8", par: 4, strokes: 4), Hole(name: "9", par: 4, strokes: 4),
//				Hole(name: "10", par: 3, strokes: 3), Hole(name: "11", par: 4, strokes: 5), Hole(name: "12", par: 4, strokes: nil),
//			])
		}

		self.currentHole = startingHole
		
		let decreaseStrokesSubject = PassthroughSubject<Void, Never>()
		let increaseStrokesSubject = PassthroughSubject<Void, Never>()
		let holeNameSubject = CurrentValueSubject<String, Never>(startingHole.name)
		let previousHoleSubject = PassthroughSubject<Void, Never>()
		let nextHoleSubject = PassthroughSubject<Void, Never>()
		self.inputs = Inputs(
			decreaseStrokes: decreaseStrokesSubject,
			increaseStrokes: increaseStrokesSubject,
			holeName: holeNameSubject,
			previousHole: previousHoleSubject,
			nextHole: nextHoleSubject
		)

		decreaseStrokesSubject
			.sink(receiveValue: { [weak self] _ in
				guard let self = self else { return }
				let numStrokes = (self.strokes ?? 0) - 1
				self.strokes = numStrokes >= 1 ? numStrokes : nil
			})
			.store(in: &self.disposables)

		increaseStrokesSubject
			.sink(receiveValue: { [weak self] _ in
				guard let self = self else { return }
				self.strokes = (self.strokes ?? 0) + 1
			})
			.store(in: &self.disposables)

		Publishers.CombineLatest(holeNameSubject, self.$parOption)
			// .debounce().filter() prevents cycle when this chain updates currentHole
			.debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
			.filter({ [weak self] holeName, parOption in
				guard let self = self else { return false }
				return self.currentHole.name != holeName || self.currentHole.par != parOption.rawValue
			})
			.map({ holeName, par in
				Hole(name: holeName, par: par.rawValue, strokes: nil)
			})
			.assign(to: &self.$currentHole)
		
		self.$currentHole
			.sink(receiveValue: { [weak self] hole in
				guard let self = self else { return }
				
				holeNameSubject.send(hole.name)
				self.parOption = ParOption(rawValue: hole.par) ?? RoundViewModel.defaultPar
				self.strokes = hole.strokes
			})
			.store(in: &self.disposables)
	}
	
	enum ParOption: Int, CaseIterable {
		case two = 2
		case three = 3
		case four = 4
		case five = 5
		case six = 6
	}
}
