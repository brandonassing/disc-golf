
import SwiftUI

struct HomeView: View {
	
	@State private var activeItem: Item?
	
    var body: some View {
		NavigationView {
			ScrollView {
				Spacer()
					.frame(height: 50)
				
				ForEach(Item.allCases, id: \.displayName) { item in
					Button(action: { self.activeItem = item }) {
						Text(item.displayName)
					}
					.buttonStyle(.bordered)
				}
				.sheet(item: self.$activeItem) { item in
					item.route
				}

			}
			.navigationTitle("Pocket Caddy")
		}
		.navigationViewStyle(.stack)
	}
	
	enum Item: String, CaseIterable {
		case newRound
	}
}

extension HomeView.Item: Displayable, Identifiable {
	
	var id: String {
		return self.rawValue
	}
	
	var displayName: String {
		switch self {
		case .newRound:
			return "New round"
		}
	}
	
	var route: some View {
		switch self {
		case .newRound:
			return RoundView()
		}
	}

}
