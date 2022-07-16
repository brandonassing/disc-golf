
extension Collection {
	func item(at index: Index) -> Element? {
		return self.indices.contains(index) ? self[index] : nil
	}
}
