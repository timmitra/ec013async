import Combine

@MainActor
class EntryController: ObservableObject {
  @Published private(set) var entries: [Entry] = []
  
  init() {
    NotificationReceiver.shared.receiveNumbers { number in
      self.entries.append(Entry(number: number))
    }
  }
}

extension EntryController {
  func nextEntry() {
    NotificationPoster.shared.selectNextNumber()
  }
}
