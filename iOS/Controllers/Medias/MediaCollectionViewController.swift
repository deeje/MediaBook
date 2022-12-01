//
//  MediaCollectionViewController.swift
//  MediaBook
//
//  Created by deeje cooley on 02/23/2002.
//  Copyright © 2022 deeje LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudCore
import AVKit
import PhotosUI
import os.log

import Viewer

// swiftlint:disable force_cast
// swiftlint:disable identifier_name
class MediaCollectionViewController: UICollectionViewController, Storyboarded {
    
    private static let cellReuseID = "media"
    
    let persistentContainer: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    let observer: CoreDataContextObserver
    
    var frc: NSFetchedResultsController<Media>!
    var cellRegistration: UICollectionView.CellRegistration<MediaCell, NSManagedObjectID>!
    var diffableDataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>!
    
    let progress = Progress()
    var totalCountObserver: Any?
    var currentCountObserver: Any?
    
    var allowsMultipleSelection = false {
        didSet {
            if let selectedItems = self.collectionView.indexPathsForSelectedItems {
                for selectedItem in selectedItems {
                    collectionView.deselectItem(at: selectedItem, animated: true)
                }
            }
            
            collectionView.allowsMultipleSelection = allowsMultipleSelection
            
            configureButtons()
        }
    }
    
    init?(coder: NSCoder, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.viewContext = persistentContainer.viewContext
        self.observer = CoreDataContextObserver(context: self.viewContext)
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Media"
        
        configureLayout()
        configureDataSource()
        configureFRC()
        
        configureButtons()
        
        configureProgressView()
        
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    func configureLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] collectionView, indexPath, mediaID in
            guard let self = self else { return nil }
                        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellReuseID, for: indexPath) as! MediaCell
            
            if cell.persistentContainer == nil {
                cell.persistentContainer = self.persistentContainer
            }
            if cell.observer == nil {
                cell.observer = self.observer
            }
            
            cell.media = try! self.viewContext.existingObject(with: mediaID) as! Media
            
            return cell
        }
        
        collectionView.dataSource = diffableDataSource
    }
    
    func configureFRC() {
        let fetchRequest = NSFetchRequest<Media>(entityName: "Media")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        self.frc = frc
        
        do {
            try frc.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    func configureButtons() {
        if collectionView.allowsMultipleSelection {
            let doneAction = UIAction(title: "Done", image: nil) { [weak self] action in
                guard let self = self else { return }
                
                self.allowsMultipleSelection = false
            }
            let doneButton = UIBarButtonItem(title: "Done", image: nil, primaryAction: doneAction, menu: nil)
            
            let download = UIAction(title: "Download", image: UIImage(systemName: "icloud.and.arrow.down")) { _ in
                DispatchQueue.main.async {
                    self.downloadSelected()
                }
            }
            let unload = UIAction(title: "Remove Download", image: UIImage(systemName: "cloud")) { _ in
                DispatchQueue.main.async {
                    self.unloadSelected()
                }
            }
            let delete = UIAction(title: "Delete…", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                DispatchQueue.main.async {
                    self.confirmDeleteSelected()
                }
            }
            let actionMenu = UIMenu(title: "Menu", children: [download, unload, delete])
            let actionButton = UIBarButtonItem(title: "Action", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: actionMenu)
            
            navigationItem.leftBarButtonItems = [doneButton]
            navigationItem.rightBarButtonItem = actionButton
        } else {
            let photoAction = UIAction(title: "Photos", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] action in
                self?.importImage()
            }
            let fileAction = UIAction(title: "Files", image: UIImage(systemName: "folder")) { [weak self] action in
                self?.importDocuments()
            }
            let pasteAction = UIAction(identifier: .paste) { [weak self] action in
                self?.handlePaste()
            }
            let importMenu = UIMenu(title: "Menu", children: [photoAction, fileAction, pasteAction])
            let importButton = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: importMenu)
            
            let selectAction = UIAction(title: "Select", image: nil) { [weak self] action in
                self?.allowsMultipleSelection = true
            }
            let selectButton = UIBarButtonItem(title: "Select", image: nil, primaryAction: selectAction, menu: nil)
            
            navigationItem.leftBarButtonItems = [selectButton]
            navigationItem.rightBarButtonItems = [importButton]
        }
    }
    
    func configureProgressView() {
        let totalCountPath: KeyPath<Progress, Int64> = \.totalUnitCount
        totalCountObserver = progress.observe(totalCountPath) { progress, change in
            print("totalCount changed = \(change.newValue ?? 0)")
        }
        
        let currentCountPath: KeyPath<Progress, Int64> = \.completedUnitCount
        currentCountObserver = progress.observe(currentCountPath) { progress, change in
            print("currentCount changed = \(change.newValue ?? 0)")
        }
    }
    
}


extension Array {

    init(cfArray: CFArray) {
        self = (0..<CFArrayGetCount(cfArray)).map {
            unsafeBitCast(
               CFArrayGetValueAtIndex(cfArray, $0),
               to: Element.self
            )
        }
    }
    
}


// MARK: Paste

extension MediaCollectionViewController {
    
    func importFrom(itemProvider provider: NSItemProvider) {
        guard provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else { return }

        let _ = provider.loadFileRepresentation(for: UTType.image) { url, inPlace, error in
            guard let url,
                  let data = NSData(contentsOf: url),
                  let source = CGImageSourceCreateWithData(data, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
                  let colorSpace = cgImage.colorSpace,
                  let cgMeta = CGImageSourceCopyMetadataAtIndex(source, 0, nil),
                  let cfTags = CGImageMetadataCopyTags(cgMeta),
                  error == nil else
            {
                if let error = error as NSError? {
                    os_log("load photo failed: %@, info: %@",
                           log: OSLog.model,
                           type: .error,
                           error.localizedDescription,
                           error.userInfo)
                }
                
                return
            }
            
            do {
                var size = CGSize(width: cgImage.width, height: cgImage.height)
                var orientation: UIImage.Orientation = .up
                let tags = Array<CGImageMetadataTag>(cfArray: cfTags)
                for tag in tags {
                    let name = CGImageMetadataTagCopyName(tag)
                                        
                    if name! as String == "Orientation" {
                        let value = CGImageMetadataTagCopyValue(tag)
                        let orientationString = value as! String
                        switch orientationString {
                        case "1":               // up
                            orientation = .up
                        case "2":
                            orientation = .upMirrored
                        case "3":               // down
                            orientation = .down
                        case "4":
                            orientation = .downMirrored
                        case "5":
                            orientation = .left
                        case "6":                 // left
                            orientation = .right
                        case "7":
                            orientation = .rightMirrored
                        case "8":
                            orientation = .leftMirrored
                        default:
                            break;
                        }
                        
                        if ["5", "6", "7", "8"].contains(orientationString) {
                            size = CGSize(width: cgImage.height, height: cgImage.width)
                        }
                    }
                }
                var rotatedImage = cgImage.rotated(for: orientation, with: size, in: colorSpace)
                var image = UIImage(cgImage: rotatedImage)
                
                let fileName = UUID().uuidString
                var tempURL = try FileManager.default.url(for: .cachesDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: true)
                tempURL.appendPathComponent(fileName)
                tempURL.appendPathExtension("png")
                
                let imageData = image.fixOrientation().pngData()
                try imageData?.write(to: tempURL)
                
                Media.addImage(from: tempURL, in: self.persistentContainer)
            } catch {
                if let error = error as NSError? {
                    os_log("copy photo failed: %@, info: %@",
                           log: OSLog.model,
                           type: .error,
                           error.localizedDescription,
                           error.userInfo)
                }
            }
        }
    }
    
    func handlePaste() {
        let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "import paste")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pasteboard = UIPasteboard.general
            for itemProvider in pasteboard.itemProviders {
                self.importFrom(itemProvider: itemProvider)
            }
            
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
    
}
// MARK: Import from Photos

extension MediaCollectionViewController: PHPickerViewControllerDelegate {
    
    func importImage() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .any(of: [.images])
        config.preferredAssetRepresentationMode = .current
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        
        present(pickerViewController, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "import photos")
            
            DispatchQueue.global(qos: .userInitiated).async {
                for result in results {
                    let provider = result.itemProvider
                    
                    self.importFrom(itemProvider: provider)
                }
                
                UIApplication.shared.endBackgroundTask(backgroundTask)
            }
            
        }
    }
    
}


// MARK: UIDocumentPickerDelegate

extension MediaCollectionViewController: UIDocumentPickerDelegate {
    
    func importDocuments() {
        let viewController = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
        viewController.delegate = self
        
        present(viewController, animated: true) {
            viewController.allowsMultipleSelection = true
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "import photos")
        
        DispatchQueue.global(qos: .userInitiated).async {
            for url in urls {
                do {
                    let sourceFileName = url.lastPathComponent
                    let suffix = sourceFileName.components(separatedBy: ".").last ?? "document"
                    
                    let tempFileName = UUID().uuidString
                    var tempURL = try FileManager.default.url(for: .cachesDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true)
                    tempURL.appendPathComponent(tempFileName)
                    tempURL.appendPathExtension(suffix)
                    
                    let imageData = try Data(contentsOf: url)
                    try imageData.write(to: tempURL)
                    
                    Media.addImage(from: tempURL, in: self.persistentContainer)
                } catch {
                    if let error = error as NSError? {
                        os_log("copy movie failed: %@, info: %@",
                               log: OSLog.model,
                               type: .error,
                               error.localizedDescription,
                               error.userInfo)
                    }
                }
            }
            
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
    
}


// MARK: Drag

extension MediaCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        var dragItems: [UIDragItem] = []

        if let mediaID = self.diffableDataSource.itemIdentifier(for: indexPath),
           let mediaMO = try? viewContext.existingObject(with: mediaID) as? Media,
           let imageMO = mediaMO.image,
           imageMO.localAvailable == true
        {
            let itemProvider = NSItemProvider(contentsOf: imageMO.url, contentType: UTType.image)
            itemProvider.suggestedName = mediaMO.exportTitle()
            
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItems.append(dragItem)
        }
        
        return dragItems
    }
    
}


// MARK: Drop

extension MediaCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        for dropItem in coordinator.items {
            let provider = dropItem.dragItem.itemProvider
            
            self.importFrom(itemProvider: provider)
        }
    }
    
}


// MARK: NSFetchedResultsControllerDelegate

extension MediaCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }

}


// MARK: UICollectionViewDelegate

extension MediaCollectionViewController {
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAt indexPath: NSIndexPath) -> Bool {
        guard collectionView.allowsMultipleSelection else { return true }
        
        let indexPath = indexPath as IndexPath
        
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection { return }
        
        let mediaID = self.diffableDataSource.itemIdentifier(for: indexPath)!
        let media = try! viewContext.existingObject(with: mediaID) as! Media
        
        if let image = media.image {
            if let lastError = image.lastErrorMessage {
                showError(message: lastError, for: mediaID)
            } else if image.localAvailable {
                let viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
                viewerController.dataSource = self
                present(viewerController, animated: false, completion: nil)
            } else if image.readyToDownload {
                download([mediaID])
            }
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let mediaID = self.diffableDataSource.itemIdentifier(for: indexPath)!
        
        let unload = UIAction(title: "Remove Download", image: UIImage(systemName: "cloud")) { _ in
            DispatchQueue.main.async {
                self.unload([mediaID])
            }
        }
        
        let delete = UIAction(title: "Delete…", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            DispatchQueue.main.async {
                self.confirmDelete([mediaID])
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [unload, delete])
        }
    }
    
    func confirmDelete(_ mediaIDs: [NSManagedObjectID]) {
        let alert = UIAlertController(title: "Delete this media?", message: "This cannot be undone", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delete(mediaIDs)
            self.allowsMultipleSelection = false
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.allowsMultipleSelection = false
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func confirmDeleteSelected() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        
        let selectedIDs = indexPaths.map { indexPath in
            return self.diffableDataSource.itemIdentifier(for: indexPath)!
        }
        
        confirmDelete(selectedIDs)
    }
    
    func showError(message: String, for mediaID: NSManagedObjectID) {
        let alert = UIAlertController(title: "Last Error", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func download(_ mediaIDs: [NSManagedObjectID]) {
        persistentContainer.performBackgroundTask { moc in
            for mediaID in mediaIDs {
                if let media = try? moc.existingObject(with: mediaID) as? Media,
                   let cacheable = media.image,
                   cacheable.readyToDownload == true
                {
                    cacheable.cacheState = .download
                }
            }
            
            if moc.hasChanges {
                try? moc.save()
            }
        }
        
        self.allowsMultipleSelection = false
    }
    
    
    func downloadSelected() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        
        let selectedIDs = indexPaths.map { indexPath in
            return self.diffableDataSource.itemIdentifier(for: indexPath)!
        }
        
        download(selectedIDs)
    }
    
    func unload(_ mediaIDs: [NSManagedObjectID]) {
        self.persistentContainer.performBackgroundTask { moc in
            do {
                for mediaID in mediaIDs {
                    if let media = try? moc.existingObject(with: mediaID) as? Media,
                       let imageMO = media.image
                    {
                        imageMO.cacheState = .unload
                    }
                }
                try moc.save()
            } catch {
                // TODO: catch errors
            }
        }
        
        self.allowsMultipleSelection = false
    }
    
    func unloadSelected() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        
        let selectedIDs = indexPaths.map { indexPath in
            return self.diffableDataSource.itemIdentifier(for: indexPath)!
        }
        
        unload(selectedIDs)
    }
    
    func delete(_ mediaIDs: [NSManagedObjectID]) {
        self.persistentContainer.performBackgroundPushTask { moc in
            do {
                for mediaID in mediaIDs {
                    if let media = try? moc.existingObject(with: mediaID) as? Media {
                        moc.delete(media)
                    }
                }
                try moc.save()
            } catch {
                // TODO: catch errors
            }
        }
    }
    
}


// MARK: ViewerControllerDataSource

extension MediaCollectionViewController: ViewerControllerDataSource {
    
    func numberOfItemsInViewerController(_ viewerController: ViewerController) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func viewerController(_ viewerController: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        let mediaID = self.diffableDataSource.itemIdentifier(for: indexPath)!
        let media = try! viewContext.existingObject(with: mediaID) as! Media
        
        var viewable = media.image
        if viewable == nil {
            viewable = media.thumbnail
        }
        return viewable!
    }
    
}
