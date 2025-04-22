//
//  MediaCell.swift
//  MediaBook
//
//  Created by deeje cooley on 02/23/2002.
//  Copyright © 2022 deeje LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudCore

class MediaCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var cloudStatusView: UIImageView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    weak var persistentContainer: NSPersistentContainer?
    weak var observer: CoreDataContextObserver?
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? tintColor.cgColor : UIColor.clear.cgColor
        }
    }
    
    private func updateImageState() {
        if let cacheable = media?.video ?? media?.image {
            var statusImage: UIImage?
            var newTint: UIColor?
            
            let readyToUpload: [CacheState] = [.local, .upload, .uploading]
            let readyToDownload: [CacheState] = [.remote, .download, .downloading]
            
            if cacheable.lastErrorMessage != nil {
                statusImage = UIImage(systemName: "exclamationmark.icloud")
                newTint = .systemRed
            } else if readyToUpload.contains(cacheable.cacheState) {
                statusImage = UIImage(systemName: "icloud.and.arrow.up")
                if cacheable.cacheState != .local {
                    newTint = .systemYellow
                }
            } else if readyToDownload.contains(cacheable.cacheState) {
                statusImage = UIImage(systemName: "icloud.and.arrow.down")
                if cacheable.remoteStatus == .pending {
                    newTint = .systemGray
                } else if cacheable.cacheState != .remote {
                    newTint = .systemYellow
                }
            }
            cloudStatusView.image = statusImage
            cloudStatusView.tintColor = newTint
            
            let progress = Float(cacheable.progress)
            if progress > progressView.progress {
                progressView.progress = progress
            }
            progressView.isHidden = progress == 0
        } else {
            cloudStatusView.image = nil
            cloudStatusView.tintColor = nil
            progressView.progress = 0
            progressView.isHidden = true
        }
    }
    
    private func updateThumbnailImage() {
        if let cacheable = media?.thumbnail,
           cacheable.localAvailable == true,
           let data = try? Data(contentsOf: cacheable.url)
        {
            DispatchQueue.global(qos: .userInteractive).async {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        } else {
            self.imageView.image = nil
        }
    }
    
    weak var media: Media? {
        willSet {
            if let image = media?.image {
                observer?.unobserveObject(object: image)
            }
            if let video = media?.video {
                observer?.unobserveObject(object: video)
            }
            if let thumbnail = media?.thumbnail {
                observer?.unobserveObject(object: thumbnail)
            }
            
            imageView.image = nil
            progressView.progress = 0
            progressView.isHidden = true
        }
        didSet {
            label.text = media?.createdAt?.formatted(date: .numeric, time: .omitted)
            
            
            updateImageState()
            updateThumbnailImage()
            
            if let imageMO = media?.image {
                observer?.observeObject(object: imageMO) { [weak self] object, state in
                    self?.updateImageState()
                }
            }
            
            if let videoMO = media?.video {
                observer?.observeObject(object: videoMO) { [weak self] object, state in
                    self?.updateImageState()
                }
            }
            
            if let thumbnailMO = media?.thumbnail {
                observer?.observeObject(object: thumbnailMO) { [weak self] object, state in
                    self?.updateThumbnailImage()
                    self?.fetchThumbnail()
                }
            }
            
            fetchThumbnail()
        }
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        media = nil
    }
    
    func fetchThumbnail() {
        guard let thumbnailMO = media?.thumbnail else { return }

        if thumbnailMO.readyToDownload {
            persistentContainer?.performBackgroundTask { moc in
                guard let cacheable = try? moc.existingObject(with: thumbnailMO.objectID) as? CloudCoreCacheable else { return }
                
                cacheable.cacheState = .download
                
                try? moc.save()
            }
        }
    }
    
}
