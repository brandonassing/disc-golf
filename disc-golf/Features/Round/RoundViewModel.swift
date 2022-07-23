
import Combine
import Foundation

class RoundViewModel: ObservableObject {
	
	static let defaultPar = ParOption.three
	static let defaultHoleName = "1"
	static let maxHoles = 18
	static let maxStrokes = 12
	
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
	
	// TODO: update currentHole/scorecard connection. It feels bloated
	@Published var currentHole: Hole
	@Published var scorecard: Scorecard
	
	@Published var isOnFirstThrow: Bool = true
	@Published var isOnLastThrow: Bool = false

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
			self.scorecard = Scorecard(id: UUID(), name: nil, holes: [startingHole], startTime: Date(), endTime: nil)
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
				let newStrokes = (self.strokes ?? 0) + 1
				guard newStrokes <= RoundViewModel.maxStrokes else { return }
				self.strokes = newStrokes
			})
			.store(in: &self.disposables)
		
		self.$strokes
			.sink(receiveValue: { [weak self] strokes in
				guard let self = self else { return }
				if let strokes = strokes {
					self.isOnFirstThrow = strokes < 1
					self.isOnLastThrow = strokes >= RoundViewModel.maxStrokes
				} else {
					self.isOnFirstThrow = true
					self.isOnLastThrow = false
				}
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
				self.scorecard = Scorecard(id: self.scorecard.id, name: self.scorecard.name, holes: holes, startTime: self.scorecard.startTime, endTime: nil)
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
		
		previousHoleSubject
			.map({ [weak self] _ -> Hole? in
				guard let self = self else { return nil }
				let currentIndex = self.scorecard.holes.firstIndex(where: { $0.id == self.currentHole.id })
				guard let currentIndex = currentIndex, currentIndex > 0 else { return nil }
				return self.scorecard.holes[currentIndex - 1]
			})
			.sink(receiveValue: { [weak self] previousHole in
				guard let self = self, let previousHole = previousHole else { return }
				self.currentHole = previousHole
			})
			.store(in: &self.disposables)
		
		nextHoleSubject
			.map({ [weak self] _ -> Int? in
				guard let self = self else { return nil }
				return self.scorecard.holes.firstIndex(where: { $0.id == self.currentHole.id })
			})
			.sink(receiveValue: { [weak self] currentIndex in
				guard
					let self = self,
					let currentIndex = currentIndex,
					self.scorecard.holes.count < RoundViewModel.maxHoles
				else { return }
				if currentIndex >= self.scorecard.holes.count - 1 {
					var holes = self.scorecard.holes
					let newHole = Hole(id: UUID(), name: "\(currentIndex + 2)", par: RoundViewModel.defaultPar.rawValue, strokes: nil)
					holes.append(newHole)
					self.scorecard = Scorecard(id: self.scorecard.id, name: self.scorecard.name, holes: holes, startTime: self.scorecard.startTime, endTime: nil)
					self.currentHole = newHole
				} else {
					self.currentHole = self.scorecard.holes[currentIndex + 1]
				}
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
