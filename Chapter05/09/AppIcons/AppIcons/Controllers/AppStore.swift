import Foundation
import Combine
import UIKit.UIImage
import UIKit.UIDevice
import Distributed

@MainActor
class AppStore: ObservableObject {
  @Published private(set) var apps = [AppInfo]()
  @Published private(set) var images = [String: UIImage]()
  @Published private(set) var isUpdating = false
  @Published private(set) var downloadedImages = 0
  private var searcher: Searcher?
  @Published private(set) var otherSearchers: [Searcher] = []
  @Published private(set) var appSearches: [String: String] = [:]
  private var downloadTask: Task<Void, Never>?
}

extension AppStore {
  func search(for rawText: String)  {
    if let _ = self.searcher {
      setSearcher(with: UIDevice.current.name)
    }
    resetSearch(for: rawText)
    downloadTask = Task {
      do {
        try await Tracker.$searchTerm.withValue(rawText) {
          apps = try await retrieveApps(for: rawText)
          try await Tracker.$totalImages.withValue(apps.count) {
            await ProgressMonitor.shared.reset()
            print(apps)
            try await retrieveImages()
          }
        }
      } catch {
        isUpdating = false
        print(error.localizedDescription)
      }
    }
  }
}

extension AppStore {
  private func retrieveApps(for rawText: String)
  async throws -> [AppInfo] {
    isUpdating = true
    let (data, _)
    = try await ephemeralURLSession
      .data(from: url(for: rawText))
    let searchResults
    = try JSONDecoder().decode(SearchResults.self,
                               from: data)
    return searchResults.apps
  }
}

extension AppStore {
  private func retrieveImages() async throws {
    try await withThrowingTaskGroup(of: (UIImage?,
                                     String).self) { group in
      for app in apps {
        group.addTask { @ProgressMonitor in
          try await Tracker.$appName.withValue(app.name) {
            async let (imageData, _)
            = try await ephemeralURLSession
              .data(from: app.artworkURL)
            let image = UIImage(data: try await imageData)
            let numberDownloaded
            = await ProgressMonitor.shared.registerImageDownload()
            await self.setDownloadedImages(to: numberDownloaded)
            return (image, app.name)
          }
        }
      }
      for try await (image, name) in group {
        downloadedImages = await ProgressMonitor.shared.downloaded
        publish(image: image, 
                forAppNamed: name)
      }
      isUpdating = false
    }
  }
}

extension AppStore {
  private func publish(image: UIImage?,
                       forAppNamed name: String) {
    if let image {
      images[name] = image
    }
  }
}

extension AppStore {
  private func resetSearch(for rawText: String) {
    downloadTask?.cancel()
    apps.removeAll()
    images.removeAll()
    downloadedImages = 0
  }
}

extension AppStore {
  var totalImages: Int {
    apps.count
  }
}

extension AppStore {
  func setDownloadedImages(to downloadedImages: Int) {
    self.downloadedImages = downloadedImages
  }
}

extension AppStore {
  nonisolated
  func setSearcher(with name: String) {
    Task {
      let searcher = Searcher(name: name,
                              appStore: self,
                              actorSystem: LocalTestingDistributedActorSystem())
      await MainActor.run {
        self.searcher = searcher
      }
    }
  }
}
