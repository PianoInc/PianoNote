//
//  UXAlbumFolderView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

protocol UXAlbumFolderProtocol: NSObjectProtocol {
    func album(folder selected: AlbumInfo)
}

class UXAlbumFolderView: UITableView {
    
    weak var delegates: UXAlbumFolderProtocol!
    
    private let imageManager = PHCachingImageManager()
    private var albumAssets = [AlbumInfo]()
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        backgroundColor = .white
        register(UXAlbumFolderCell.self, forCellReuseIdentifier: "UXAlbumFolderCell")
        allowsSelection = false
        dataSource = self
        delegate = self
        
        fetchAlbum()
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
        if albums.count > 0 {
            for album in albums.objects(at: IndexSet(0...albums.count - 1)) {
                addAlbum(asset: album)
            }
        }
    }
    
    private func addAlbum(asset: PHAssetCollection) {
        let albumPhotos = PHAsset.fetchAssets(in: asset, options: nil)
        if albumPhotos.count > 0 {
            let photo = albumPhotos.lastObject!
            let size = CGSize(width: PHImageManagerMinimumSize, height: PHImageManagerMinimumSize)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: photo, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
                let albumInfo = AlbumInfo(type: asset.assetCollectionType,
                                          subType: asset.assetCollectionSubtype,
                                          image: image, title: asset.localizedTitle, count: albumPhotos.count)
                self.albumAssets.append(albumInfo)
            }
        }
    }
    
}

extension UXAlbumFolderView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("albumAssets.count :", albumAssets.count)
        print(albumAssets)
        return albumAssets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UXAlbumFolderCell") as! UXAlbumFolderCell
        cell.delegates = self
        cell.indexPath = indexPath
        
        cell.thumbnailView.image = albumAssets[indexPath.row].image
        cell.titleLabel.text = albumAssets[indexPath.row].title
        cell.countLabel.text = "\(albumAssets[indexPath.row].count)"
        
        return cell
    }
    
}

protocol UXAlbumFolderCellProtocol: NSObjectProtocol {
    func action(indexPath: IndexPath)
}

extension UXAlbumFolderView: UXAlbumFolderCellProtocol {
    
    func action(indexPath: IndexPath) {
        delegates.album(folder: albumAssets[indexPath.row])
    }
    
}

class UXAlbumFolderCell: UITableViewCell {
    
    weak var delegates: UXAlbumFolderCellProtocol!
    
    fileprivate let thumbnailView = makeView(UIImageView()) {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    fileprivate let titleLabel = makeView(UILabel()) {
        $0.textColor = .black
    }
    fileprivate let countLabel = makeView(UILabel()) {
        $0.textColor = .gray
    }
    
    fileprivate let button = UIButton()
    
    fileprivate var indexPath: IndexPath!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        contentView.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints {
            $0.leading.equalTo(15); $0.top.equalTo(15)
            $0.bottom.equalTo(-15); $0.width.equalTo(85)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailView.snp.trailing).offset(15)
            $0.top.equalTo(15); $0.bottom.equalTo(-50)
            $0.width.lessThanOrEqualToSuperview().inset(100)
        }
        
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailView.snp.trailing).offset(15)
            $0.top.equalTo(50); $0.bottom.equalTo(-15)
            $0.width.lessThanOrEqualToSuperview().inset(100)
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

