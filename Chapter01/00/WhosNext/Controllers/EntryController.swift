class EntryController {
  private var count = 0
  private let vendor = PlainEntryVendor()
  private(set) var entries: [Entry] = []
}

extension EntryController {
  func next() {
    count += 1
    let entriesCopy = entries
    let newEntry = vendor.entry(for: count)
    entries = entriesCopy + [newEntry]
  }
}
