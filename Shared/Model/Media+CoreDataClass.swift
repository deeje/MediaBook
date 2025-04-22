//
//  Media+CoreDataClass.swift
//
//  Created by deeje cooley on 4/18/22.
//

import CoreData
import AVFoundation
import UIKit
import os.log

@objc(Media)
public class Media: NSManagedObject {
    
    enum MediaType: String {
        case unknown
        case image
        case video
    }
    
    static func add(from url: URL, as contents: Datafile.Contents, in persistentContainer: NSPersistentContainer) {
        persistentContainer.performBackgroundPushTask { moc in
            do {
                let mediaMO = Media(context: moc)
                mediaMO.createdAt = Date()
                mediaMO.mediaType = contents == .video ? .video : .image
                
                let imageMO = Datafile(context: moc)
                imageMO.cacheState = .local
                imageMO.remoteStatus = .pending
                imageMO.contents = contents == .video ? .video : .image
                imageMO.media = mediaMO
                try FileManager.default.moveItem(at: url, to: imageMO.url)
                
                var thumbnailData: Data?
                if contents == .video {
                    let asset = AVURLAsset(url: imageMO.url)
                    let generator = AVAssetImageGenerator(asset: asset)
                    generator.maximumSize = CGSize(width: 400, height: 0)
                    generator.requestedTimeToleranceBefore = .zero
                    generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
                    if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil)
                    {
                        let thumbnailImage = UIImage(cgImage: cgImage)
                        thumbnailData = thumbnailImage.pngData()
                    }
                } else {
                    let thumbnailImage = UIImage.resizedImage(at: imageMO.url, for: CGSize(width: 320, height: 240))!
                    thumbnailData = thumbnailImage.pngData()
                }
                
                if let thumbnailData {
                    let thumbnailMO = Datafile(context: moc)
                    thumbnailMO.cacheState = .local
                    thumbnailMO.remoteStatus = .pending
                    thumbnailMO.contents = .thumbnail
                    thumbnailMO.media = mediaMO
                    try thumbnailData.write(to: thumbnailMO.url)
                }
                
                try moc.save()
            } catch {
                if let error = error as NSError? {
                    os_log("addImage failed: %@, info: %@",
                           log: OSLog.model,
                           type: .error,
                           error.localizedDescription,
                           error.userInfo)
                }
            }
        }

    }
    
    private func datafile(of contents: Datafile.Contents) -> Datafile? {
        guard let files = datafiles?.allObjects as? [Datafile] else { return nil }
        
        let file = files.first { $0.contents == contents }
        
        return file
    }
    
    var mediaType: MediaType {
        get {
            return mediaTypeRaw == nil ? .unknown : MediaType(rawValue: mediaTypeRaw!)!
        }
        set {
            mediaTypeRaw = newValue.rawValue
        }
    }

    var image: Datafile? {
        return datafile(of: .image)
    }
    
    var video: Datafile? {
        return datafile(of: .video)
    }
    
    var thumbnail: Datafile? {
        return datafile(of: .thumbnail)
    }
    
    func exportTitle() -> String! {
        var newTitle = title
        if newTitle == nil {
            newTitle = createdAt!.formatted(date: .numeric, time: .shortened)
            newTitle = newTitle?.replacingOccurrences(of: "/", with: "-")
            newTitle = newTitle?.replacingOccurrences(of: ":", with: "-")
            switch mediaType {
            case .image:
                newTitle?.append(".png")
            case .video:
                newTitle?.append(".mp4")
            default:
                break
            }
        }
        return newTitle!
    }
    
}
