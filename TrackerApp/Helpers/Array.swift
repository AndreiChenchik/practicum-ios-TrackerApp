extension Array where Element: Equatable {
    func startingFrom(_ element: Element) -> Array? {
        guard let index = self.firstIndex(where: { $0 == element }) else { return nil }

        return Array(self[index..<self.count]) + Array(self[0..<index])
    }
}
