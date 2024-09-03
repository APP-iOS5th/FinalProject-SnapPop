//
//  SnapPhotoViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/12/24.
//

import UIKit

class SnapPhotoViewController: UIViewController {
    
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            updateImage()
        }
    }
    var index: Int = 0
    
    // MARK: - UIComponents
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackgroundColor
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        updateImage()
    }
    
    // MARK: - Methods
    private func updateImage() {
        if let image = image {
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.layer.masksToBounds = true
            }
        } else {
            print("nil Image")
        }
    }
}
