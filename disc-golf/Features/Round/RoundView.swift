
import SwiftUI

struct RoundView: View {
	
	@State private var holeName = RoundViewModel.defaultHoleName
	
	@StateObject private var viewModel: RoundViewModel
	
	@Environment(\.dismiss) var dismiss

	init(scorecard: Scorecard? = nil) {
		self._viewModel = StateObject(wrappedValue: RoundViewModel(scorecard: scorecard))
	}
	
    var body: some View {
		NavigationView {
			VStack(spacing: 50) {
				ScorecardView(viewModel: ScorecardViewModel(scorecard: self.viewModel.scorecard))
					.padding()
				
				VStack {
					VStack {
						Text("Par")
						
						Picker("Par", selection: self.$viewModel.parOption) {
							ForEach(RoundViewModel.ParOption.allCases, id: \.rawValue) { parOption in
								Text("\(parOption.rawValue)")
									.tag(parOption)
							}
						}
						.pickerStyle(.segmented)
					}
					
					Spacer()
						.frame(height: 20)
					
					VStack(spacing: 10) {
						Text("Throws")
						
						HStack(spacing: 50) {
							Button(action: self.viewModel.inputs.decreaseStrokes.send) {
								Image(systemName: "minus")
							}
							
							if let strokes = self.viewModel.strokes {
								Text("\(strokes)")
							} else {
								Text("-")
							}
							
							Button(action: self.viewModel.inputs.increaseStrokes.send) {
								Image(systemName: "plus")
							}
						}
					}
					
					Spacer()
					
					HStack(spacing: 50) {
						Button(action: self.viewModel.inputs.previousHole.send) {
							Image(systemName: "chevron.left")
						}
						
						// TODO: prevent empty string. Maybe just disable next/back button? This would allow user to completely change a hole name (ie: change "1" to "2")
						TextField("Hole", text: self.$holeName)
							.frame(width: 50)
							.multilineTextAlignment(.center)
							.onChange(of: self.holeName, perform: { holeName in
								// TODO: should this logic be moved to vm?
								guard holeName.count <= 3 else {
									self.holeName = String(holeName.prefix(3))
									return
								}
								self.viewModel.inputs.holeName.send(holeName)
							})
							.onReceive(self.viewModel.$currentHole, perform: { currentHole in
								self.holeName = currentHole.name
							})
						
						Button(action: self.viewModel.inputs.nextHole.send) {
							Image(systemName: "chevron.right")
						}
					}
				}
				
				Button(action: {}) {
					NavigationLink(
						destination: RoundCompletionView(
							scorecard: self.viewModel.scorecard,
							dismiss: { self.dismiss.callAsFunction() }
						)
					) {
						Text("End round")
					}
				}
				.buttonStyle(.bordered)
			}
			.padding()
			.navigationBarHidden(true)
			
		}
	}
}
