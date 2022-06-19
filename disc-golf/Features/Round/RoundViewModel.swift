
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
		
		var startingHole = Hole(id: UUID(), name: RoundViewModel.defaultHoleName, par: RoundViewModel.defaultPar.rawValue, strokes: nil)
		
		if let scorecard = scorecard, !scorecard.holes.isEmpty {
			self.scorecard = scorecard
			if let firstHole = scorecard.holes.first, let parOption = ParOption(rawValue: firstHole.par) {
				startingHole = firstHole
				self.parOption = parOption
				self.strokes = firstHole.strokes
			}
		} else {
			self.scorecard = Scorecard(name: nil, holes: [startingHole])
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

		Publishers.CombineLatest3(holeNameSubject, self.$parOption, self.$strokes)
			// .debounce().filter() prevents cycle when this chain updates currentHole
			.debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
			.filter({ [weak self] holeName, parOption, strokes in
				guard let self = self else { return false }
				return self.currentHole.name != holeName || self.currentHole.par != parOption.rawValue || self.currentHole.strokes != strokes
			})
			.map({ [weak self] holeName, par, strokes -> Hole? in
				guard let self = self else { return nil }
				return Hole(id: self.currentHole.id, name: holeName, par: par.rawValue, strokes: strokes)
			})
			.sink(receiveValue: { [weak self] hole in
				guard let self = self, let hole = hole else { return }
				
				var holes = self.scorecard.holes
				
				let index = holes.firstIndex(where: { $0.id == self.currentHole.id })
				guard let index = index else { return }
				holes.removeAll(where: { $0.id == self.currentHole.id })
				holes.insert(hole, at: index)
				self.scorecard = Scorecard(name: self.scorecard.name, holes: holes)
				self.currentHole = hole
			})
			.store(in: &self.disposables)
		
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
