//
//  ViewController.swift
//  Camera
//
//  Created by Rizwan on 16/06/17.
//  Copyright © 2017 Rizwan. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Hero
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    var longitude: Float = 21.25
    var latitude: Float = 21.5

    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    let instagram = Instagram()

    @IBOutlet weak var blackView: UIView!



    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var imageView: UIView!

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var qrCodeFrameView: UIView?

    var photosByTag: [(String, String)] = []
    var photosByLocation: [(String, String)] = []
    var relevantTag: String?


    var googleAPIKey = "AIzaSyCR-th9Bylxi4PCgf3m6q8LcvPMPZtNaBU"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))

        self.hero.isEnabled = true
        blackView.hero.id = "button"


        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
        captureButton.clipsToBounds = true

        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization();

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Initialize the captureSession object
            captureSession = AVCaptureSession()

            // Set the input devcie on the capture session
            captureSession?.addInput(input)

            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true

            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)

            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]



            DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.view.layer.bounds
                self.previewView.layer.addSublayer(self.videoPreviewLayer!)
                self.captureSession?.startRunning()
            }

            messageLabel.isHidden = true
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }

    }

    @objc func onTap() {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }

        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()

        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto

        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {

            longitude = Float(location.coordinate.longitude)
            latitude = Float(location.coordinate.latitude)

        }
    }

    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = view.bounds
        if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapTakePhoto(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }

        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()

        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto

        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)

    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {


    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }

        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }

        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.messageLabel.text = "CAPTURED"
            let binaryImageData = self.base64EncodeImage(image)
            self.createRequest(with: binaryImageData)
        }

    }
}

extension ViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.isHidden = true
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                messageLabel.isHidden = false
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}



/// Image processing

extension ViewController {

    func analyzeResults(_ dataToParse: Data) {

        // Update UI on the main thread
        DispatchQueue.main.async(execute: {


            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]

            self.messageLabel.isHidden = false

            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.messageLabel.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response

                let responses: JSON = json["responses"][0]
                let results: JSON = responses["webDetection"]

                // Get label annotations
                let labelAnnotations: JSON = results["bestGuessLabels"][0]

                let numLabels: Int = labelAnnotations.count
                //var labels: Array<String> = []
                if numLabels > 0 {
                    self.messageLabel.text = "\(labelAnnotations["label"])"
                    self.relevantTag = "\(labelAnnotations["label"])"
                    self.instagram.setLocationQuery(longitude: self.longitude, latitude: self.latitude)
                    self.instagram.setTagQuery(query: "\(labelAnnotations["label"])")
                    self.instagram.fetchTagData(completion: { (tagData) in
                        for data in tagData {
                            self.photosByTag.append((data.url, data.caption))
                        }

                        let suggestionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuggestionViewController") as! SuggestionViewController
                        suggestionViewController.photosByTag = [self.photosByTag]
                        suggestionViewController.tags = [self.relevantTag ?? ""]
                        self.present(suggestionViewController, animated: true, completion: nil)

//                            self.performSegue(withIdentifier: "toSuggestedView", sender: nil)
                        })


                } else {
                    self.messageLabel.text = "No labels found"
                }
            }
        })

    }

    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


/// Networking

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = image.pngData()

        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }

        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }

    func createRequest(with imageBase64: String) {
        // Create our request URL

        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "WEB_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)

        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }

        request.httpBody = data

        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }

    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request

        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }

            self.analyzeResults(data)
        }

        task.resume()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestedView" {
            let suggestionViewController = segue.destination as! SuggestionViewController
            suggestionViewController.photosByTag = [self.photosByTag]
            suggestionViewController.photosByLocation = [self.photosByLocation]

//            print("my son wya: \(self.photosByTag[0].0)")
            suggestionViewController.tags = [self.relevantTag ?? ""]
        }
    }
}
