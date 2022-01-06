//
//  MilioAlbumView.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit
class MilioAlbumView: MilioBaseView {
    
    public var albums: [MilioAlbum] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    public var titleAlbum = ""
    weak var albumDelegate: MLOAlbumDelegate?
    let tableView = UITableView()
    override func setupComponent() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(MilioAlbumCell.self, forCellReuseIdentifier: "AlbumCell")
        tableView.backgroundColor = .clear
    }
    override func setupConstraint() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
extension MilioAlbumView: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! MilioAlbumCell
        bindView(cell: cell, album: album)
        return cell
    }
    func bindView(cell: MilioAlbumCell, album: MilioAlbum) {
        cell.thumbnail.image = album.thumbnail
        cell.title.text = album.title
        cell.numberOfItems.text = "\(album.numberOfItems)"
        cell.accessoryType = titleAlbum == album.title ? .checkmark : .none
    }
}
extension MilioAlbumView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        albumDelegate?.didSelectIndexAlbum(with: indexPath.row)
    }
}
