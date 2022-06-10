
import SwiftUI

struct RoundView: View {
	
	@State private var parOption = RoundViewModel.defaultPar.rawValue
	@State private var holeName = RoundViewModel.defaultHoleName
	
	@StateObject private var viewModel: RoundViewModel

	init(scorecard: Scorecard? = nil) {
		self._viewModel = StateObject(wrappedValue: RoundViewModel(scorecard: scorecard))
	}
	
    var body: some View {
		VStack {
			ScorecardView(scorecard: self.viewModel.scorecard)
				.padding()
			
			Spacer()
				.frame(height: 50)
			
			VStack {
				Text("Par")

				Picker("Par", selection: self.$parOption) {
					ForEach(RoundViewModel.ParOption.allCases, id: \.rawValue) { parOption in
						Text("\(parOption.rawValue)")
							.tag(parOption.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: self.parOption, perform: { par in
					self.viewModel.inputs.par.send(par)
				})
				.onReceive(self.viewModel.$currentHole, perform: { currentHole in
					self.parOption = currentHole.par
				})
				
				Spacer()
				HStack {
					Text("Throws")
				}
				Spacer()
				HStack(spacing: 50) {
					Button(action: self.viewModel.inputs.previousHole.send) {
						Image(systemName: "chevron.left")
					}
					
					TextField("Hole", text: self.$holeName)
						.frame(width: 50)
						.multilineTextAlignment(.center)
						.onChange(of: self.holeName, perform: { holeName in
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
		}
		.padding()
	}
}
