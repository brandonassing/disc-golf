
import SwiftUI

struct HomeView: View {
	
	@State private var activeItem: Item?
	
    var body: some View {
		NavigationView {
			ScrollView {
				Spacer()
					.frame(height: 50)
				
				ForEach(Item.allCases, id: \.displayName) { item in
					Button(action: {
						if item.isModal {
							self.activeItem = item
						}
					}) {
						if !item.isModal {
							NavigationLink(destination: item.route()) {
								Text(item.displayName)
							}
						} else {
							Text(item.displayName)
						}
					}
					.buttonStyle(.bordered)
				}
				.sheet(item: self.$activeItem) { item in
					item.route()
				}

			}
			.navigationTitle("Pocket Caddy")
		}
		.navigationViewStyle(.stack)
	}
	
	enum Item: String, CaseIterable {
		case newRound
		case roundHistory
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
		case .roundHistory:
			return "Round history"
		}
	}
	
	var isModal: Bool {
		switch self {
		case .newRound:
			return true
		case .roundHistory:
			return false
		}
	}
	
	@ViewBuilder
	func route() -> some View {
		switch self {
		case .newRound:
			RoundView()
		case .roundHistory:
			RoundHistoryView()
		}
	}
}
