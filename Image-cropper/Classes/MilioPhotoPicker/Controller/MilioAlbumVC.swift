//
//  MilioAlbumVC.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit
class MilioAlbumVC: MilioBaseVC {
    public var didSelectIndexAlbum: ((_ crurrentIndexAlbum: Int) -> Void)?
    public var milioAlbum = MilioAlbumView()
    public var albums: [MilioAlbum] = [] {
        didSet{
            milioAlbum.albums = albums
        }
    }
    public var titleAlbum: String = ""{
        didSet{
            milioAlbum.titleAlbum = titleAlbum
        }
    }
    override func setupComponent() {
        setupNavigationBar()
        view.addSubview(milioAlbum)
        milioAlbum.albumDelegate = self
    }
    override func setupConstraint() {
        milioAlbum.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension MilioAlbumVC{
    func setupNavigationBar() {
        title = "Gallary"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
    }
    
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
}
extension MilioAlbumVC: MLOAlbumDelegate{
    func didSelectIndexAlbum(with crurrentIndexAlbum: Int) {
        didSelectIndexAlbum?(crurrentIndexAlbum)
        self.dismiss(animated: true, completion: nil)
    }
}
