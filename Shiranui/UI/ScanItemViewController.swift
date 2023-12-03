//
//  ScanItemViewController.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import UIKit
import PhotosUI
import Vision

class ScanItemViewController: UIViewController {
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var optionsStackView: UIStackView!
    
    override func viewDidLoad() {
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        self.titleLabel = UILabel()
        titleLabel.text = "Scan Barcode"
        titleLabel.font = .boldSystemFont(ofSize: 45)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        self.subtitleLabel = UILabel()
        //        subtitleLabel.text = "Scan the barcode of a Vinyl or CD by either uploading an image from your photo gallery or holding the barcode close to the camera"
        subtitleLabel.numberOfLines = -1
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        let galleryOption = makeImageGalleryOption()
        let cameraOption = makeCameraOption()
        let buttons = [galleryOption, cameraOption]
        
        self.optionsStackView = UIStackView(arrangedSubviews: buttons)
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            optionsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            
            galleryOption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            galleryOption.trailingAnchor.constraint(equalTo: cameraOption.leadingAnchor, constant: -20),
        ])
        
        for button in buttons {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 170)
            ])
        }
    }
    
    func createOptionButton(title: String, subtitle: String, imageSystemName: String) -> UIButton {
        var conf = UIButton.Configuration.plain()
        conf.background.backgroundColor = .tertiarySystemFill
        conf.image = UIImage(systemName: imageSystemName)?.withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        conf.imagePadding = 10
        conf.imagePlacement = .top
        
        conf.attributedTitle = AttributedString(title,
                                                attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 20)]))
        conf.attributedSubtitle = AttributedString(subtitle,
                                                   attributes: AttributeContainer([.foregroundColor: UIColor.secondaryLabel,
                                                                                   .font: UIFont.italicSystemFont(ofSize: 12)]))

        return UIButton(configuration: conf)
    }
    
    
    func makeImageGalleryOption() -> UIView {
        let button = createOptionButton(title: "Image Gallery", 
                                        subtitle: "Pick an image from your gallery which contains a barcode.", imageSystemName: "photo.stack.fill")
        button.addTarget(self, action: #selector(imageGalleryButtonSelected), for: .touchUpInside)
        return button
    }

    func makeCameraOption() -> UIView {
        let button = createOptionButton(title: "Scan from Camera", 
                                        subtitle: "Point your device's camera at a barcode to scan it.", imageSystemName: "camera")
        
        button.addTarget(self, action: #selector(cameraOptionTapped), for: .touchUpInside)
        return button
    }
    
    @objc
    func cameraOptionTapped() {
        let vc = CameraScannerViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @objc
    func imageGalleryButtonSelected() {
        var conf = PHPickerConfiguration()
        conf.selectionLimit = 1
        conf.filter = .images
        let picker = PHPickerViewController(configuration: conf)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func fadeInProgress() -> UIActivityIndicatorView {
        let progressView = UIActivityIndicatorView()
        progressView.startAnimating()
        progressView.style = .large
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return progressView
    }
    
    
    func errorOut(title: String, subtitle: String?, indicator: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            self.subtitleLabel.isHidden = false
            self.subtitleLabel.alpha = 1
            
            self.titleLabel.text = title
            self.subtitleLabel.text = subtitle
            
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            
            var conf = UIButton.Configuration.borderedProminent()
            conf.cornerStyle = .large
            
            let dismissButton = UIButton(configuration: conf)
            dismissButton.setTitle("OK", for: .normal)
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            dismissButton.addTarget(self, action: #selector(self.okButtonTapped), for: .touchUpInside)
            self.view.addSubview(dismissButton)
            
            NSLayoutConstraint.activate([
                dismissButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
                dismissButton.heightAnchor.constraint(equalToConstant: 50),
                dismissButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
                dismissButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            ])
        }
    }
    
    @objc func okButtonTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        print("We have de-initialized")
    }
}

extension ScanItemViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            guard let first = results.first else { return }
            
            self.titleLabel.font = .boldSystemFont(ofSize: 35)
            self.titleLabel.text = "Scanning..."
            
            self.animateViewsFading(views: [self.subtitleLabel, self.optionsStackView], hide: true) {
                let indicator = self.fadeInProgress()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    first.itemProvider.loadObject(ofClass: UIImage.self) { item, error in
                        if let error {
                            self.errorOut(title: "Error", subtitle: error.localizedDescription, indicator: indicator)
                            return
                        }
                        
                        guard let asCGImage = (item as? UIImage)?.cgImage else {
                            self.errorOut(title: "Error", subtitle: "Couldn't read image", indicator: indicator)
                            return
                        }
                        
                        let request = VNDetectBarcodesRequest()
                        let handler = VNImageRequestHandler(cgImage: asCGImage)
                        
                        do {
                            try handler.perform([request])
                        } catch {
                            self.errorOut(title: "Couldn't find barcode", subtitle: error.localizedDescription, indicator: indicator)
                            return
                        }
                        
                        guard let result = request.results?.first else {
                            self.errorOut(title: "Error", subtitle: "No barcodes were found in the provided image.", indicator: indicator)
                            return
                        }
                        
                        guard let barcodeString = result.payloadStringValue else {
                            self.errorOut(title: "Error", subtitle: "Couldn't get barcode value", indicator: indicator)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.titleLabel.text = "Fetching..."
                        }
                        
                        print("String: \(barcodeString)")
                        Task {
                            do {
                                try await self.fetchAlbum(withBarcodeString: barcodeString, indicator: indicator)
                            } catch {
                                self.errorOut(title: "Error", subtitle: error.localizedDescription, indicator: indicator)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchAlbum(withBarcodeString barcodeString: String, indicator: UIActivityIndicatorView) async throws {
        let results = try await AlbumFetcher.shared.album(withBarcodeString: barcodeString)
        let album: Album?
        
        if barcodeString.first == "0" {
            var zeroStrippedVersion = barcodeString
            zeroStrippedVersion.removeFirst()
            print(zeroStrippedVersion)
            
            album = results.results.first { album in
                album.barcodes.contains(barcodeString) || album.barcodes.contains(zeroStrippedVersion)
            }
        } else {
            album = results.results.first { album in
                album.barcodes.contains(barcodeString)
            }
        }
        
        guard let album else {
            self.errorOut(title: "Couldn't find album.", subtitle: nil, indicator: indicator)
            return
        }
        
        Preferences.userScannedAlbums.append(album)
        dismiss(animated: true)
    }
}

extension ScanItemViewController: CameraScannerViewControllerDelegate {
    func cameraScanner(_ scanner: CameraScannerViewController, didRecognizeBarCode barcodeString: String) {
        scanner.dismiss(animated: true)
        
        self.animateViewsFading(views: [self.subtitleLabel, self.optionsStackView], hide: true) {
            let indicator = self.fadeInProgress()
            
            self.titleLabel.font = .boldSystemFont(ofSize: 35)
            self.titleLabel.text = "Fetching..."
            
            Task {
                do {
                    try await self.fetchAlbum(withBarcodeString: barcodeString, indicator: indicator)
                } catch {
                    self.errorOut(title: "Error", subtitle: error.localizedDescription, indicator: indicator)
                }
            }
        }
    }
}
