//
//  ViewController.swift
//  SwiftCoreImageFilter
//
//  Created by Prashant on 16/11/15.
//  Copyright © 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    // Outlet & action - camera button 
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBAction func cameraButtonAction(sender: AnyObject) {
        // show action shee to choose image source.
        self.showImageSourceActionSheet()
    }
    
    
    // Outlet & action - save button
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBAction func saveButtonAction(sender: UIBarButtonItem) {
        // save image to photo gallery
        self.saveImageToPhotoGallery()
    }
    
    
    // Outlet - image preview
    @IBOutlet var previewImageView: UIImageView!
    
    
    // Selected image
    var selctedImage: UIImage!

    
    // message label
    @IBOutlet var messageLabel: UILabel!
    
    
    // filter Title and Name list
    var filterTitleList: [String]!
    var filterNameList: [String]!
    
    
    // filter selection picker
    @IBOutlet var filterPicker: UIPickerView!
    
    
    
    
    // MARK: - view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set filter title list array.
        self.filterTitleList = ["(( Choose Filter ))" ,"PhotoEffectChrome", "PhotoEffectFade", "PhotoEffectInstant", "PhotoEffectMono", "PhotoEffectNoir", "PhotoEffectProcess", "PhotoEffectTonal", "PhotoEffectTransfer"]
        
        // set filter name list array.
        self.filterNameList = ["No Filter" ,"CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
        
        // set delegate for filter picker
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
        
        // disable filter pickerView
        self.filterPicker.userInteractionEnabled = false
        
        // show message label
        self.messageLabel.hidden = false
        
        // disable save button
        self.saveButton.enabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: image picker delegate function
    
    // set selected image in preview
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // dismiss image picker controller
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // if image selected the set in preview.
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // set selected image into variable
            self.selctedImage = newImage
            
            // set preview for selected image
            self.previewImageView.image = self.selctedImage
            
            // enable filter pickerView
            self.filterPicker.userInteractionEnabled = true
            
            // hide message label
            self.messageLabel.hidden = true
            
            // disable save button
            self.saveButton.enabled = false
            
            // set filter pickerview to default position
            self.filterPicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    // Close image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // dismiss image picker controller
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    // MARK: - picker view delegate and data source (to choose filter name)

    // how many component (i.e. column) to be displayed within picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // How many rows are there is each component
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filterTitleList.count
    }
    
    // title/content for row in given component
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.filterTitleList[row]
    }
    
    // called when row selected from any component within picker view
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // disable save button if filter not selected.
        // enable save button if filter selected.
        if row == 0 {
            self.saveButton.enabled = false
        }else{
            self.saveButton.enabled = true
        }
        
        // call funtion to apply the selected filter
        self.applyFilter(selectedFilterIndex: row)
    }
    
    
    
    
    // MARK: - Utility functions {
    
    // Show action sheet for image source selection
    private func showImageSourceActionSheet() {
        
        // create alert controller having style as ActionSheet
        let alertCtrl = UIAlertController(title: "Select Image Source" , message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // create photo gallery action
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: UIAlertActionStyle.Default, handler: {
                (alertAction) -> Void in
                self.showPhotoGallery()
            }
        )
        
        // create camera action
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {
                (alertAction) -> Void in
                self.showCamera()
            }
        )
        
        // create cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        // add action to alert controller
        alertCtrl.addAction(galleryAction)
        alertCtrl.addAction(cameraAction)
        alertCtrl.addAction(cancelAction)
        
        // do this setting for ipad
        alertCtrl.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = alertCtrl.popoverPresentationController
        popover?.barButtonItem = self.cameraButton
        
        
        // present action sheet
        self.presentViewController(alertCtrl, animated: true, completion: nil)
    }
    
    
    // Show photo gallery to choose image
    private func showPhotoGallery() -> Void {

        // debug
        print("Choose - Photo Gallery")
        
        // show picker to select image form gallery
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
        
            // create image picker
            let imagePicker = UIImagePickerController()
            
            // set image picker property
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            // do this settings to show popover within iPad
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = imagePicker.popoverPresentationController
            popover!.barButtonItem = self.cameraButton
            
            // show image picker
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }else{
            self.showAlertMessage(alertTitle: "Not Supported", alertMessage: "Device can not access gallery.")
        }
        
    }

    
    // Show camera to capture image
    private func showCamera() -> Void {

        // debug
        print("Choose - Camera")
        
        // show camera
        if( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            // create image picker
            let imagePicker = UIImagePickerController()

            // set image picker property
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
            imagePicker.allowsEditing = false
            
            // do this settings to show popover within iPad
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = imagePicker.popoverPresentationController
            popover!.barButtonItem = self.cameraButton
            
            // show image picker with camera.
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }else {
            self.showAlertMessage(alertTitle: "Not Supported", alertMessage: "Camera not supported in emulator.")
        }
        
    }
    
    
    // apply filter to current image
    private func applyFilter(selectedFilterIndex filterIndex: Int) {
    
        print("Filter - \(self.filterNameList[filterIndex)")
        
        /* filter name
        0 - NO Filter,
        1 - PhotoEffectChrome, 2 - PhotoEffectFade, 3 - PhotoEffectInstant, 4 - PhotoEffectMono,
        5 - PhotoEffectNoir, 6 - PhotoEffectProcess, 7 - PhotoEffectTonal, 8 - PhotoEffectTransfer
        */
        
        // if No filter selected then apply default image and return.
        if filterIndex == 0 {
            // set image selected image
            self.previewImageView.image = self.selctedImage
            return
        }
        
        
        // Create and apply filter
        // 1 - create source image
        let sourceImage = CIImage(image: self.selctedImage)
        
        // 2 - create filter using name
        let myFilter = CIFilter(name: self.filterNameList[filterIndex])
        myFilter?.setDefaults()
        
        // 3 - set source image
        myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - create core image context
        let context = CIContext(options: nil)
        
        // 5 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage(myFilter!.outputImage!, fromRect: myFilter!.outputImage!.extent)

        // 6 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(CGImage: outputCGImage)

        // 7 - set filtered image to preview
        self.previewImageView.image = filteredImage
    }
    
    
    // save imaage to photo gallery
    private func saveImageToPhotoGallery(){
        // Save image
        dispatch_async(dispatch_get_main_queue() ) {
            UIImageWriteToSavedPhotosAlbum(self.previewImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    
    // show message after image saved to photo gallery.
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
        // show success or error message.
        if error == nil {
            self.showAlertMessage(alertTitle: "Success", alertMessage: "Image Saved To Photo Gallery")
        } else {
            self.showAlertMessage(alertTitle: "Error!", alertMessage: (error?.localizedDescription)! )
        }
        
    }
    
    
    // Show alert message with OK button
    func showAlertMessage(alertTitle alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

        myAlertVC.addAction(okAction)
        
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
    
    
}

