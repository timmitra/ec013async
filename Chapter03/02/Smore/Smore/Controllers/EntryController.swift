import Combine

@MainActor
class EntryController: ObservableObject {
  @Published private(set) var entries: [Entry] = []
  
  init() {
    Task {
      await listenForNumbers()
    }
  }
}

extension EntryController {
  private func listenForNumbers() async {
    for await number in NotificationReceiver.shared.numbers {
      entries.append(Entry(number: number))
    }
  }
}

extension EntryController {
  func nextEntry() {
    NotificationPoster.shared.selectNextNumber()
  }
}
