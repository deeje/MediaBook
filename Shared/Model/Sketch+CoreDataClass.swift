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
    
    static func addImage(from url: URL, in persistentContainer: NSPersistentContainer) {
        persistentContainer.performBackgroundPushTask { moc in
            do {
                let mediaMO = Media(context: moc)
                mediaMO.createdAt = Date()
                
                let imageMO = Datafile(context: moc)
                imageMO.cacheState = .local
                imageMO.remoteStatus = .pending
                imageMO.contents = .image
                imageMO.media = mediaMO

                try FileManager.default.moveItem(at: url, to: imageMO.url)
                
                let thumbnailMO = Datafile(context: moc)
                thumbnailMO.cacheState = .local
                thumbnailMO.remoteStatus = .pending
                thumbnailMO.contents = .thumbnail
                thumbnailMO.media = mediaMO

                let thumbnailImage = UIImage.resizedImage(at: imageMO.url, for: CGSize(width: 320, height: 240))!
                let thumbnailData = thumbnailImage.pngData()
                try thumbnailData?.write(to: thumbnailMO.url)
                
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
    
    var image: Datafile? {
        return datafile(of: .image)
    }
    
    var thumbnail: Datafile? {
        return datafile(of: .thumbnail)
    }
    
}
