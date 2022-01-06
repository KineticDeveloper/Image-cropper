//
//  MilioBaseVC.swift
//  Image-cropper
//
//  Created by P-THY on 6/1/22.
//

import UIKit

public class MilioBaseVC: UIViewController ,UIGestureRecognizerDelegate{
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = barAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        }
        // Do any additional setup after loading the view.
        setupView()
        setupViewDidLoad()
        setupComponent()
        setupConstraint()
    }
    
    func setupComponent() {}
    func setupConstraint() {}
    func setupViewDidLoad() {}
    func setupView() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .white
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
}
//MARK: - Handle Event
extension MilioBaseVC {
    @objc func hideKeybord (){
        view.endEditing(true)
    }
}
