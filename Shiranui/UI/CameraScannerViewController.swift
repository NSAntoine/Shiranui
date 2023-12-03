//
//  CameraScannerViewController.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import UIKit
import AVFoundation

class CameraScannerViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13]
    
    // The "Point your device at the barcode" label
    var label: UILabel?
    // the blur infront of the label
    var blurView: UIVisualEffectView?
    var shouldFadeBlurAway: Bool = true
    
    weak var delegate: CameraScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputsAndAddLayer()
    }
    
    func setupCaptureDeviceUnavailableUI() {
        addBlurAndLabel(labelText: "Camera Unavailable.")
    }
    
    func configureInputsAndAddLayer() {
        let captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(metadataOutput) else {
            self.shouldFadeBlurAway = false
            setupCaptureDeviceUnavailableUI()
            return
        }
        
        self.captureSession = captureSession
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = supportedBarcodeTypes
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        self.addBlurAndLabel(labelText: "Point your device's camera at the barcode.")
        captureSession.startRunning()
    }
    
    func addBlurAndLabel(labelText: String) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = -1
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.blurView = blur
        self.label = label
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let captureSession = self.captureSession, !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let views = [blurView, label].compactMap { $0 }
        if shouldFadeBlurAway, !views.isEmpty {
            animateViewsFading(views: views, duration: 1, hide: true) {
                self.blurView = nil
                self.label = nil
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let captureSession = self.captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    deinit {
        print("CameraScannerViewController de-initialized.")
    }
}

extension CameraScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first,
              let readableObject = previewLayer?.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        captureSession?.stopRunning()
        
        self.delegate?.cameraScanner(self, didRecognizeBarCode: stringValue)
    }
}

protocol CameraScannerViewControllerDelegate: AnyObject {
    func cameraScanner(_ scanner: CameraScannerViewController, didRecognizeBarCode: String)
}
