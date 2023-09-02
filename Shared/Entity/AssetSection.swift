import Foundation

struct AssetSection {
  var start: Date
  var end: Date
  var assets: [Asset]

  var interval: DateInterval {
    .init(start: start, end: end)
  }
}

func createSections(assets: [Asset], photos: [Photo], tags: [Tag]) -> [AssetSection] {
  assets.reduce(into: [AssetSection]()) { partialResult, asset in
    guard let assetCreationDate = asset.phAsset.creationDate else {
      return
    }

    if let lastSection = partialResult.last {
      var section = lastSection

      if section.end < assetCreationDate {
        section.end = assetCreationDate
      }

      if !Calendar.current.isDate(section.start, inSameDayAs: assetCreationDate) {
        if section.assets.count > 8 {
          let newSection = AssetSection(start: assetCreationDate, end: assetCreationDate, assets: [asset])
          partialResult.append(newSection)
          return
        }
      }

      section.assets.append(asset)
      partialResult[partialResult.count - 1] = section

    } else {
      let section = AssetSection(start: assetCreationDate, end: assetCreationDate, assets: [asset])
      partialResult.append(section)
    }
  }
}
