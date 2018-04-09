//
//  DRAlbumPhotoListView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

class DRAlbumPhotoListView: UICollectionView {
    
    weak var delegates: DRAlbumDelegates!
    
    private let emptyImage = makeView(UIImageView()) {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .red
    }
    
    private let imageManager = PHCachingImageManager()
    private var photoFetchResult = PHFetchResult<PHAsset>() { didSet {
        photoAssets = reverse(photo: photoFetchResult)
        reloadData()
        }}
    private var photoAssets = [PHAsset]()
    var albumTitle = ""
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initView()
        initConst()
        fetchPhoto()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initConst()
        fetchPhoto()
    }
    
    private func initView() {
        register(DRAlbumPhotoCell.self, forCellWithReuseIdentifier: "DRAlbumPhotoCell")
        backgroundColor = UIColor(hex6: "eeeeee")
        allowsSelection = false
        dataSource = self
        delegate = self
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 2
            flowLayout.minimumLineSpacing = 2
        }
        addSubview(emptyImage)
    }
    
    private func initConst() {
        makeConst(emptyImage) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func fetchPhoto() {
        if let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject {
            PHPhotoLibrary.shared().register(self)
            photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
            albumTitle = album.localizedTitle ?? "albumNoTitle".locale
        }
        emptyImage.isHidden = (photoFetchResult.count > 0)
    }
    
    /**
     PHFetchResult를 역순으로 만들어 Array로 반환한다.
     - parameter photo : 역순으로 하려는 PHFetchResult.
     - returns : 역순으로 바꾼 PHAsset Array.
     */
    private func reverse(photo: PHFetchResult<PHAsset>) -> [PHAsset] {
        if photo.count <= 0 {return [PHAsset]()}
        var tempArray = [PHAsset]()
        for object in photo.objects(at: IndexSet(0...photo.count - 1)) {
            tempArray.append(object)
        }
        return tempArray.reversed()
    }
    
    /// albumInfo에 기반하여 photo를 reload한다.
    func requestPhoto(from albumInfo: AlbumInfo) {
        if albumInfo.type.rawValue == 1 { // 네이버 클라우드와 같은 외부 폴더
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            for album in albums.objects(at: IndexSet(0...albums.count - 1)) where album.localizedTitle == albumInfo.title {
                photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                albumTitle = album.localizedTitle ?? "albumNoTitle".locale
            }
        } else {
            if let album = PHAssetCollection.fetchAssetCollections(with: albumInfo.type, subtype: albumInfo.subType, options: nil).firstObject {
                photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                albumTitle = album.localizedTitle ?? "albumNoTitle".locale
            }
        }
    }
    
    /// 주어진 direction대로 list의 Content 방향을 바꾼다.
    func change(direction: UICollectionViewScrollDirection) {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.scrollDirection = direction
        reloadData()
    }
    
}

extension DRAlbumPhotoListView: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let newPhotos = changeInstance.changeDetails(for: photoFetchResult) else {return}
        photoFetchResult = newPhotos.fetchResultAfterChanges
        DispatchQueue.main.async {
            if newPhotos.hasIncrementalChanges {
                self.performBatchUpdates({
                    if let removed = newPhotos.removedIndexes, !removed.isEmpty {
                        self.deleteItems(at: removed.map({IndexPath(item: $0, section: 0)}))
                    }
                    if let inserted = newPhotos.insertedIndexes, !inserted.isEmpty {
                        self.insertItems(at: inserted.map({IndexPath(item: $0, section: 0)}))
                    }
                    if let changed = newPhotos.changedIndexes, !changed.isEmpty {
                        self.reloadItems(at: changed.map({IndexPath(item: $0, section: 0)}))
                    }
                    newPhotos.enumerateMoves { from, to in
                        self.moveItem(at: IndexPath(item: from, section: 0), to: IndexPath(item: to, section: 0))
                    }
                })
            } else {
                self.reloadData()
            }
        }
    }
    
}

extension DRAlbumPhotoListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        }
        
        // 전체화면에서 보여주고자 하는 Cell의 갯수.
        var portCellNum: CGFloat = 3
        var landCellNum: CGFloat = 6
        if UIDevice.current.userInterfaceIdiom == .pad {
            portCellNum = portCellNum * 2
            landCellNum = landCellNum * 2
        }
        // 아이템 간격만큼 제외한 넓이를 구하기 위한 spacing 값.
        let portCutSpacing = flowLayout.minimumInteritemSpacing * (portCellNum - 1)
        let landCutSpacing = flowLayout.minimumInteritemSpacing * (landCellNum - 1)
        
        var cellSize = collectionView.bounds.height
        if flowLayout.scrollDirection == .vertical {
            cellSize = floor((collectionView.bounds.width - portCutSpacing) / portCellNum)
            if UIApplication.shared.statusBarOrientation.isLandscape {
                cellSize = floor((collectionView.bounds.width - landCutSpacing) / landCellNum)
            }
        }
        return CGSize(width: cellSize, height: cellSize)
    }
    
}

extension DRAlbumPhotoListView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRAlbumPhotoCell", for: indexPath) as! DRAlbumPhotoCell
        cell.delegates = delegates
        cell.indexPath = indexPath
        
        let photo = photoAssets[indexPath.row]
        let size = CGSize(width: PHImageManagerMinimumSize, height: PHImageManagerMinimumSize)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        imageManager.requestImage(for: photo, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
            cell.photoView.image = image
        }
        
        return cell
    }
    
}

