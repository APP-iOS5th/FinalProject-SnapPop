//
//  CropViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/20/24.
//

import UIKit
import Photos // Import Photos framework for saving images

class CropViewController: UIViewController {
    var imageView: UIImageView!
    var image: UIImage!
    private var homeViewModel = HomeViewModel()
    
    private var cropToolbar: CustomCropToolbar!
    private var cropRectView: UIView!
    private var cropRect: CGRect = CGRect.zero
    private var rotationLabel: UILabel!

    var didGetCroppedImage: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCropRectView()
        setupRotationLabel()
    }

    private func setupUI() {
        view.backgroundColor = .black
        setupImageView()
        setupGestureRecognizers()
        setupCropToolbar()
        setupButtons()
    }

    private func setupImageView() {
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
    }

    private func setupGestureRecognizers() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetImageOrientation))
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(rotationGesture)
        imageView.addGestureRecognizer(tapGesture)

      // 크롭 가이드라인을 이동하기 위한 팬 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cropRectView.addGestureRecognizer(panGesture)

        // 크롭 가이드라인에 핀치 제스처 추가
        let cropPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleCropPinch(_:)))
        cropRectView.addGestureRecognizer(cropPinchGesture)
    }

    private func setupCropToolbar() {
        cropToolbar = CustomCropToolbar(frame: CGRect.zero)
        cropToolbar.onCrop = { [weak self] in
            self?.cropImage() // Call the crop method when the crop button is pressed
        }
        self.view.addSubview(cropToolbar)

        cropToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cropToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cropToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cropToolbar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupButtons() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelCrop), for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.lightGray
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.masksToBounds = true

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("완료", for: .normal)
        doneButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        doneButton.backgroundColor = UIColor.yellow
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true

        self.view.addSubview(cancelButton)
        self.view.addSubview(doneButton)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    private func setupCropRectView() {
        cropRectView = UIView()
        cropRectView.layer.borderColor = UIColor.white.cgColor
        cropRectView.layer.borderWidth = 2.0
        cropRectView.isUserInteractionEnabled = true // Enable user interaction
        self.view.addSubview(cropRectView)
        
        updateCropRectView()
    }

    private func updateCropRectView() {
        let aspectRatio: CGFloat = 5.0 / 7.0
        let width = self.view.bounds.width * 0.8
        let height = width / aspectRatio
        cropRect = CGRect(x: (self.view.bounds.width - width) / 2,
                          y: (self.view.bounds.height - height) / 2,
                          width: width,
                          height: height)
        cropRectView.frame = cropRect
    }

    private func setupRotationLabel() {
        rotationLabel = UILabel()
        rotationLabel.textColor = .white
        rotationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rotationLabel)

        NSLayoutConstraint.activate([
            rotationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rotationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
        updateCropRectView()
    }

    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed {
            imageView.transform = imageView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0.0
            
            let angle = atan2(imageView.transform.b, imageView.transform.a) * (180 / .pi)
            rotationLabel.text = String(format: "Rotation: %.1f°", angle)
        }
        updateCropRectView()
    }

     @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        if gesture.state == .changed {
            // 팬 제스처에 따라 cropRectView 이동
            cropRectView.center = CGPoint(x: cropRectView.center.x + translation.x, y: cropRectView.center.y + translation.y)
            gesture.setTranslation(.zero, in: self.view) // 변환 초기화
        }
    }

  @objc func handleCropPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        // 핀치 제스처에 따라 cropRectView의 크기 조정
        if gesture.state == .changed {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0 // 다음 변화를 위해 scale 초기화
        }
    }
    @objc func resetImageOrientation() {
        imageView.transform = .identity
        rotationLabel.text = "Rotation: 0.0°"
    }

    @objc func cropImage() {
        guard let image = imageView.image else { return }
        let scaleX = image.size.width / imageView.bounds.width
        let scaleY = image.size.height / imageView.bounds.height
        let scale = min(scaleX, scaleY)

        let scaledCropRect = CGRect(
            x: (cropRectView.frame.origin.x - imageView.frame.origin.x) * scale,
            y: (cropRectView.frame.origin.y - imageView.frame.origin.y) * scale,
            width: cropRectView.frame.size.width * scale,
            height: cropRectView.frame.size.height * scale
        )

        guard let cgImage = image.cgImage?.cropping(to: scaledCropRect) else { return }
        let croppedImage = UIImage(cgImage: cgImage)

        didGetCroppedImage?(croppedImage)

        // Save the cropped image using HomeViewModel
        homeViewModel.saveCroppedImage(croppedImage)

        let croppedImageView = UIImageView(image: croppedImage)
        croppedImageView.frame = self.view.bounds
        self.view.addSubview(croppedImageView)

        // Optionally dismiss the CropViewController after saving
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelCrop() {
        self.dismiss(animated: true, completion: nil)
    }
}
