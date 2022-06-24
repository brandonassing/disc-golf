
import SwiftUI

struct RoundNameView: View {
	
	let completion: (String) -> ()
	
	@Environment(\.presentationMode) var presentationMode
	@State private var name: String = ""
	
    var body: some View {
		VStack(spacing: 30) {
			Text("Enter a name for this course")
			
			TextField("Name", text: self.$name)
				.textFieldStyle(.roundedBorder)
			
			Button(action: {
				if !self.name.isEmpty {
					self.completion(self.name)
					self.presentationMode.wrappedValue.dismiss()
				}
			}) {
				Text("Done")
			}
			.buttonStyle(.bordered)
		}
		.padding()
	}
}
