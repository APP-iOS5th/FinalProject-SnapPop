//
//  CustomCropToolbar.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/19/24.
//

import UIKit

class CustomCropToolbar: UIView {
    
    // UI Components
    private var ratioButton: UIButton!
    private var rotateButton: UIButton! // New rotate button
    private var flipButton: UIButton! // New flip button
    private var cropButton: UIButton! // New crop button
    private var stackView: UIStackView!
    
    // Customizable properties
    var customBackgroundColor: UIColor = .black {
        didSet { self.updateBackgroundColor() }
    }
    var foregroundColor: UIColor = .white
    
    // Callbacks for button actions
    var onRatio: (() -> Void)?
    var onRotate: (() -> Void)? // Callback for rotation
    var onFlip: (() -> Void)? // Callback for flipping
    var onCrop: (() -> Void)? // Callback for cropping
    
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
        ratioButton = createButton(withTitle: "Ratio", action: #selector(showRatio))
        rotateButton = createButton(withTitle: "Rotate", action: #selector(rotate)) // Rotate button
        flipButton = createButton(withTitle: "Flip", action: #selector(flip)) // Flip button
        cropButton = createButton(withTitle: "Crop", action: #selector(crop)) // New crop button
        
        // Create stack view and add buttons
        stackView = UIStackView(arrangedSubviews: [ratioButton, rotateButton, flipButton, cropButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        // Add stack view to the toolbar
        addSubview(stackView)
        
        // Layout constraints for stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set background color
        self.backgroundColor = customBackgroundColor
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
    
    @objc private func showRatio() {
        onRatio?()
    }
    
    @objc private func rotate() {
        onRotate?() // Call the rotate callback
    }
    
    @objc private func flip() {
        onFlip?() // Call the flip callback
    }
    
    @objc private func crop() {
        onCrop?() // Call the crop callback
    }
    
    func adjustLayout(forOrientation isPortrait: Bool) {
        stackView.axis = isPortrait ? .horizontal : .vertical
        updateButtonSizes()
    }
    
    private func updateButtonSizes() {
        let screenSize = UIScreen.main.bounds.size
        let buttonWidth = screenSize.width * buttonWidthRatio
        let buttonHeight = screenSize.height * buttonHeightRatio
        
        ratioButton.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
        rotateButton.frame.size = CGSize(width: buttonWidth, height: buttonHeight) // Set size for rotate button
        flipButton.frame.size = CGSize(width: buttonWidth, height: buttonHeight) // Set size for flip button
        cropButton.frame.size = CGSize(width: buttonWidth, height: buttonHeight) // Set size for crop button
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