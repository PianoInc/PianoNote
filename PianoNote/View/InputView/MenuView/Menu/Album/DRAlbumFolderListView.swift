//
//  DRAlbumFolderListView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

/// 앨범 정보.
struct AlbumInfo {
    var type: PHAssetCollectionType
    var subType: PHAssetCollectionSubtype
    var image: UIImage!
    var title: String
    var count: Int
}

class DRAlbumFolderListView: UITableView {
    
    weak var delegates: DRAlbumDelegates!
    
    private let imageManager = PHCachingImageManager()
    var albumAssets = [AlbumInfo]()
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initView()
        fetchAlbum()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        fetchAlbum()
    }
    
    private func initView() {
        backgroundColor = .white
        register(DRAlbumFolderCell.self, forCellReuseIdentifier: "DRAlbumFolderCell")
        allowsSelection = false
        dataSource = self
        delegate = self
    }
    
    private func fetchAlbum() {
        albumAssets.removeAll()
        let subTypes: [PHAssetCollectionSubtype] = [.smartAlbumRecentlyAdded, .smartAlbumUserLibrary,
                                                    .smartAlbumSelfPortraits, .smartAlbumScreenshots]
        for type in subTypes {
            if let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: type, options: nil).firstObject {
                addAlbum(asset: album)
            }
        }
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        guard albums.count > 0 else {return}
        for album in albums.objects(at: IndexSet(0...albums.count - 1)) {
            addAlbum(asset: album)
        }
    }
    
    private func addAlbum(asset: PHAssetCollection) {
        let albumPhotos = PHAsset.fetchAssets(in: asset, options: nil)
        guard albumPhotos.count > 0, let photo = albumPhotos.lastObject else {return}
        let size = CGSize(width: PHImageManagerMinimumSize, height: PHImageManagerMinimumSize)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        imageManager.requestImage(for: photo, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
            self.albumAssets.append(AlbumInfo(type: asset.assetCollectionType,
                                              subType: asset.assetCollectionSubtype,
                                              image: image ?? nil, title: asset.localizedTitle ?? "",
                                              count: albumPhotos.count))
        }
    }
    
}

extension DRAlbumFolderListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return minSize * 0.2666
    }
    
}

extension DRAlbumFolderListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumAssets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRAlbumFolderCell") as! DRAlbumFolderCell
        cell.indexPath = indexPath
        cell.delegates = delegates
        
        cell.thumbnailView.image = albumAssets[indexPath.row].image
        cell.titleLabel.text = albumAssets[indexPath.row].title
        cell.countLabel.text = "\(albumAssets[indexPath.row].count)"
        
        return cell
    }
    
}

