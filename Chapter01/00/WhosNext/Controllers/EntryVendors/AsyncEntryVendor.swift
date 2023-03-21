struct AsyncEntryVendor  {
  func entry(for count: Int) async -> Entry {
    do {
      let imageName = try await imageName(for: count)
      return Entry(imageName: imageName)
    } catch {
      return errorEntry()
    }
  }
}

extension AsyncEntryVendor {
  private func imageName(for int: Int) async throws -> String {
    if int.isMultiple(of: 5) {
      throw MultipleOfFiveError(number: int)
    }
    let number = int % 51
    //try? await Task.sleep(for: .seconds(Int.random(in: 2...6)))
    return await number.description + suffix()
  }
}

//extension AsyncEntryVendor {
//  private var suffix: String {
//    get async {
fileprivate func suffix() async -> String {
  try? await Task.sleep(for: .seconds(Int.random(in: 2...6)))
  return ".circle"
}
//    }
//  }
//}

