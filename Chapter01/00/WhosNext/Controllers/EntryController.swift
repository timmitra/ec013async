import Combine

@MainActor
class EntryController: ObservableObject {
  private var count = 0
  @Published private(set) var entries: [Entry] = []
  private let vendor = AsyncEntryVendor()
}

extension EntryController {
  func next() {
    count += 1
    let entriesCopy = entries
    Task {
      // work to be done in the form of a closure
      // that accepts no input and optionally
      // returns a value of type Success
      let newEntry = await vendor.entry(for: count)
      entries = entriesCopy + [newEntry]
    }
  }
}
