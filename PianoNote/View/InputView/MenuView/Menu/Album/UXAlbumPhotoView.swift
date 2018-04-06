//
//  UXAlbumPhotoView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

protocol UXAlbumPhotoProtocol: NSObjectProtocol {
    func album(selected photo: UIImage)
}

class UXAlbumPhotoView: UICollectionView {
    
    weak var delegates: UXAlbumPhotoProtocol!
    
    private let emptyImage = makeView(UIImageView()) {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .red
    }
    
    private let imageManager = PHCachingImageManager()
    private var photoAssets = [PHAsset]()
    private var photoFetchResult = PHFetchResult<PHAsset>() {
        didSet {
            photoAssets = reverse(photo: photoFetchResult)
        }
    }
    
    ///  Photo를 가져올 기반이 되는 AlbumInfo.
    var albumInfo: AlbumInfo!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        register(UXAlbumPhotoCell.self, forCellWithReuseIdentifier: "UXAlbumPhotoCell")
        backgroundColor = UIColor(hex6: "eeeeee")
        allowsSelection = false
        dataSource = self
        delegate = self
        
        initLayout()
        fetchUserLibrary()
    }
    
    private func initLayout() {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
    }
    
    private func fetchUserLibrary() {
        if let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject {
            PHPhotoLibrary.shared().register(self)
            albumInfo = AlbumInfo(type: album.assetCollectionType, subType: album.assetCollectionSubtype,
                                  image: nil, title: album.localizedTitle, count: 0)
            photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
        }
        
        addSubview(emptyImage)
        emptyImage.isHidden = (photoFetchResult.count > 0)
    }
    
    /// albumInfo에 기반하여 photo를 reload한다.
    func reloadAlbum() {
        if albumInfo.type.rawValue == 1 { // 네이버 클라우드와 같은 외부 폴더
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            for album in albums.objects(at: IndexSet(0...albums.count - 1)) {
                if album.localizedTitle == albumInfo.title {
                    photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                }
            }
        } else {
            if let album = PHAssetCollection.fetchAssetCollections(with: albumInfo.type, subtype: albumInfo.subType, options: nil).firstObject {
                photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
            }
        }
        reloadData()
    }
    
    /// 주어진 ScrollDirection대로 Contents 방향을 바꾼다.
    func change(direction: UICollectionViewScrollDirection) {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.scrollDirection = direction
        reloadData()
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
    
}

extension UXAlbumPhotoView: PHPhotoLibraryChangeObserver {
    
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

extension UXAlbumPhotoView: UICollectionViewDelegateFlowLayout {
    
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

extension UXAlbumPhotoView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UXAlbumPhotoCell", for: indexPath) as! UXAlbumPhotoCell
        cell.delegates = self
        cell.indexPath = indexPath
        
        let photo = photoAssets[indexPath.row]
        let size = CGSize(width: PHImageManagerMinimumSize, height: PHImageManagerMinimumSize)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        imageManager.requestImage(for: photo, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
            cell.imageView.image = image
        }
        
        return cell
    }
    
}

protocol UXAlbumPhotoCellProtocol: NSObjectProtocol {
    func action(indexPath: IndexPath)
}

extension UXAlbumPhotoView: UXAlbumPhotoCellProtocol {
    
    /// Cell button 선택 처리.
    func action(indexPath: IndexPath) {
        let photo = photoAssets[indexPath.row]
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        imageManager.requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, _) in
            guard let image = image else {return}
            self.delegates.album(selected: image)
        }
    }
    
}

class UXAlbumPhotoCell: UICollectionViewCell {
    
    weak var delegates: UXAlbumPhotoCellProtocol!
    
    fileprivate let imageView = makeView(UIImageView()) {
        $0.isUserInteractionEnabled = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    fileprivate let button = UIButton()
    
    fileprivate var indexPath: IndexPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalTo(0); $0.top.equalTo(0); $0.bottom.equalTo(0); $0.trailing.equalTo(0)
        }
        contentView.addSubview(button)
        makeConst(button) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(action(select:)), for: .touchUpInside)
    }
    
    @objc private func action(select: UIButton) {
        delegates.action(indexPath: self.indexPath!)
    }
    
}

