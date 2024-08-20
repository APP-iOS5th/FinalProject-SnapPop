//
//  CustomCropToolbar.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/19/24.
//

import UIKit

class CustomCropToolbar: UIView {
    
    // UI Components
    private var cropButton: UIButton?
    private var cancelButton: UIButton?
    private var ratioButton: UIButton?
    private var stackView: UIStackView?
    
    // Customizable properties
    var customBackgroundColor: UIColor = .black {
            didSet { self.updateBackgroundColor() }
        }
    var foregroundColor: UIColor = .white
    
    // Callbacks for button actions
    var onCrop: (() -> Void)?
    var onCancel: (() -> Void)?
    var onRatio: (() -> Void)?
    
    // Constants based on relative screen sizes
    private var buttonWidthRatio: CGFloat = 0.3
    private var buttonHeightRatio: CGFloat = 0.06 // Height as a fraction of the screen height
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Create buttons
        cropButton = createButton(withTitle: "Crop", action: #selector(crop))
        cancelButton = createButton(withTitle: "Cancel", action: #selector(cancel))
        ratioButton = createButton(withTitle: "Ratio", action: #selector(showRatio))
        
        // Create stack view
        stackView = UIStackView(arrangedSubviews: [cancelButton!, ratioButton!, cropButton!])
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.alignment = .center
        stackView?.distribution = .fillEqually
        stackView?.axis = .horizontal
        
        // Add stack view to the toolbar
        addSubview(stackView!)
        
        // Layout constraints for stack view
        NSLayoutConstraint.activate([
            stackView!.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView!.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView!.topAnchor.constraint(equalTo: topAnchor),
            stackView!.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set background color
        self.backgroundColor = backgroundColor
    }
    
    private func createButton(withTitle title: String?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = foregroundColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle(title, for: .normal)
        button.setTitleColor(foregroundColor, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }
    
    @objc private func crop() {
        onCrop?()
    }
    
    @objc private func cancel() {
        onCancel?()
    }
    
    @objc private func showRatio() {
        onRatio?()
    }
    
    func adjustLayout(forOrientation isPortrait: Bool) {
        stackView?.axis = isPortrait ? .horizontal : .vertical
        updateButtonSizes()
    }
    
    private func updateButtonSizes() {
        let screenSize = UIScreen.main.bounds.size
        let buttonWidth = screenSize.width * buttonWidthRatio
        let buttonHeight = screenSize.height * buttonHeightRatio
        
        cropButton?.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
        cancelButton?.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
        ratioButton?.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
    }
    
    private func updateBackgroundColor() {
         self.backgroundColor = customBackgroundColor
     }
    
    override var intrinsicContentSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        let height = screenSize.height * buttonHeightRatio
        let width = screenSize.width
        
        return CGSize(width: width, height: height)
    }
}
