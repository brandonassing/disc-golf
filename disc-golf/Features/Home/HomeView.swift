
import SwiftUI

struct HomeView: View {
    var body: some View {
		NavigationView {
			ScrollView {
				ForEach(Items.allCases, id: \.displayName) { item in
					Button(action: {}) {
						NavigationLink(destination: item.route) {
							Text(item.displayName)
								.padding()
						}
					}
				}
			}
			.navigationTitle("Pocket Caddy")
		}
		.navigationViewStyle(.stack)
	}
	
	enum Items: String, CaseIterable {
		case scorecard
	}
}

extension HomeView.Items: Displayable {
	
	var displayName: String {
		switch self {
		case .scorecard:
			return "New scorecard"
		}
	}
	
	var route: some View {
		switch self {
		case .scorecard:
			return ScorecardView()
		}
	}

}
