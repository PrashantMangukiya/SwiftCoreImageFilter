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
        self.showImageSourceActionSheet()
    }
    
    
    // Outlet & action - save button
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBAction func saveButtonAction(sender: UIBarButtonItem) {
        
    }
    
    
    // Outlet - image preview
    @IBOutlet var previewImageView: UIImageView!
    
    // Selected image object
    var selctedImage: UIImage!
    
    
    // message label
    @IBOutlet var messageLabel: UILabel!
    
    
    
    // Flag indicates that Image selected or not by user.
    var isImageSelected : Bool!
    
    // filter list array
    /*
        0 - NO Filter, 1 - PhotoEffectChrome, 2 - PhotoEffectFade,
        3 - PhotoEffectInstant, 4 - PhotoEffectMono, 5 - PhotoEffectNoir,
        6 - PhotoEffectProcess, 7 - PhotoEffectTonal, 8 - PhotoEffectTransfer
    */
    var filterList: [String]!
    
    
    // filter selection picker
    @IBOutlet var filterPicker: UIPickerView!
    
    
    
    
    // MARK: - view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set filter list array.
        self.filterList = ["(( Choose Filter ))" ,"PhotoEffectChrome", "PhotoEffectFade", "PhotoEffectInstant", "PhotoEffectMono", "PhotoEffectNoir", "PhotoEffectProcess", "PhotoEffectTonal", "PhotoEffectTransfer"]
        
        // set delegate for filter picker
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
        
        // set image selected flag as false
        self.isImageSelected = false
        
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
    
    // Show selected image in preview
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // dismiss image picker controller
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // if image selected the set in preview.
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // set selected image
            self.selctedImage = newImage
            
            // set preview for selected image
            self.previewImageView.image = self.selctedImage
            
            // set image selected flag true.
            self.isImageSelected = false
            
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
        return self.filterList.count
    }
    
    // title/content for row in given component
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.filterList[row]
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
    private func applyFilter(selectedFilterIndex selectedFilterIndex: Int) {
    
        print("Selected Filter Index - \(selectedFilterIndex)")
    }
    
    
    // Show alert message with OK button
    func showAlertMessage(alertTitle alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

        myAlertVC.addAction(okAction)
        
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
    
    
}

