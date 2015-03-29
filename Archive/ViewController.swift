//
//  ViewController.swift
//  Archive
//
//  Created by Michael Stromer on 3/29/15.
//  Copyright (c) 2015 Michael Stromer. All rights reserved.
//

import UIKit

var tapRecognizer: UITapGestureRecognizer? = nil

var index = 0

func documentsDirectory() -> String {
    let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
    return documentsFolderPath
}

func fileInDocumentsDirectory(filename: String) -> String {
    return documentsDirectory().stringByAppendingPathComponent(filename)
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var inventory: Inventory!
    var inventoryPath = fileInDocumentsDirectory("inventory.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        imageView.addGestureRecognizer(tapGesture)
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
//        var item = Item(name: "Cup", cost: 9.99, imageName: "Cup.png")
//        println("item: \(item)")
//        let path = fileInDocumentsDirectory(item.name)
//        println("\(path)")
//        let success = saveItemToDisc(item, path: path)
//        var loadedItem = loadItemFromDisc(path)
        
//        if let loadItem = loadedItem {
//            
//        println("Loaded: \(loadedItem)")
//            //use unwrapped value
//        } else {
//            println("Unable to laod item at path: \(path)" )
//        }
        
        //Inventory Class
        //var inventory = Inventory()
        //println("Inventory: \(inventory)")
        
        loadInventory()
        
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadInventory() {
        if let inventory = loadInventory(fromPath: inventoryPath) {
            self.inventory = inventory
            
            println("Inventory loaded: \(self.inventory)")
        } else {
            //initialize inventory
            self.inventory = Inventory()
            println("Inventory created")
        }
    }
    func loadInventory(fromPath path: String) -> Inventory? {
        var result: Inventory? = nil
        result = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as Inventory?
        return result
    }
    func saveInventory() {
        var success = false
        
        success = saveInventory(inventory, path:inventoryPath)
        if success {
            println("Inventory saved to path: \(inventoryPath)")
        } else {
            println("Inventory failed to save to path: \(inventoryPath)")
        }
        
    }
    func saveInventory(inventory: Inventory, path: String) -> Bool {
        var success = false
        
        success = NSKeyedArchiver.archiveRootObject(inventory, toFile: path)
        if success {
            for item in inventory.itemArray {
                if let image = item.image {
                    let imagePath = fileInDocumentsDirectory(item.imageName)
                    
                    let result = saveImage(image, path: imagePath)
                    println("Saved Item Image: \(result) \(imagePath)")
                }
            }
        }
        return success
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func saveItemToDisc(item: Item, path: String) -> Bool {
        var success = false
        success = NSKeyedArchiver.archiveRootObject(item, toFile: path)
        return success
        
    }
    func loadItemFromDisc(path: String) -> Item? {
        var result: Item? = nil
        result = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as Item?
        
        return result
    }

    @IBAction func addAction(sender: AnyObject) {
        if let item = createItemFromInput() {
            inventory.itemArray.append(item)
        }
        saveInventory()
    }
    @IBAction func previousButton(sender: AnyObject) {
        
        index--
        
        if index < 0 {
                index = inventory.itemArray.count - 1
        }
        var item = inventory.itemArray[index]
        displayItem(item)
    }
    @IBAction func nextButton(sender: AnyObject) {
        if inventory.itemArray.count > 0 {
            
        if index >= inventory.itemArray.count {
            index = 0
            }
            
            var item = inventory.itemArray[index]
            displayItem(item)
            
            index++

        }
    }
    func displayItem(item: Item) {
        if item.image != nil {
            imageView.image = item.image
        } else { //load image from disc!
            var imagePath = fileInDocumentsDirectory(item.imageName)
            //var image
            if let image = loadImageFromPath(imagePath) {
            
                imageView.image = image
                
            } else {
                println("Error: Image missing for item: \(item)")
            }
        }
        itemTextField.text = item.name
        costTextField.text = "\(item.cost)"
    }
    
    func createItemFromInput() -> Item? {
        var item: Item? = nil
        
        //validate cost and title
        if let cost = validateCost(costTextField.text) {
            println("valid cost")
            if !itemTextField.text.isEmpty {
               let title = itemTextField.text
                
                if let image = imageView.image {
                    let imageName = "\(title).jpg" //create and return item
                    item = Item(name: title, cost: cost, imageName: imageName)
                    item?.image = image
                } else {
                    println("Error no image set")
                }
                
                
            } else {
                println("Error invalid title: \(itemTextField.text)")
            }
            
        }
        return item
        
    }
    func validateCost(costString: String) -> Double? {
        var result: Double? = nil
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        if let cost = numberFormatter.numberFromString(costString) {
            //cost is valid, result must equal NSNumber
            result = cost.doubleValue
        } else {
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            if let cost = numberFormatter.numberFromString(costString) {
                result = cost.doubleValue
            } else {
                println("Error! Invalid number: \(costString)")
            }
        }
     
        return result
    }
    func saveDataToDisc() {
    let itemTitle = itemTextField.text
        if !itemTitle.isEmpty {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            let itemCost = numberFormatter.numberFromString(costTextField.text)// convert text to number
            
            if itemCost != nil {
                
                //  $3.00 format
                
                if let image = imageView.image { // optional binding
                    
                    // valid image
                    
                    
                    let imagePath = fileInDocumentsDirectory("\(itemTitle).jpg")
                    
                    saveImage(image, path: imagePath)
                    
                    if let itemCostFormatted = numberFormatter.stringFromNumber(itemCost!) {
                        
                        var textDataToSave = "\(itemTitle), \(itemCostFormatted), \(imagePath)"
                        
                        println("data: \(textDataToSave)")
                        
                        let textPath = fileInDocumentsDirectory("\(itemTitle).txt")
                        
                        saveText(textDataToSave, path: textPath)
                        
                    }
                    
                } else {
                    println("Error missing image")
                }
                
                
                
                
            } else {
                println("Error missing cost or invalid $3.00 value")
            }
            
            
        } else {
            println("Error: missing item title")
        }
        
    }
    func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        println("Tap")
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as UIImage? {
            imageView.image = image
        }
    }

    func saveImage(image: UIImage, path: String) -> Bool {
        
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        // png UIImagePNG...
        let result = jpgImageData.writeToFile(path, atomically: true)
        return result
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            println("Missing image at path: \(path)")
        }
        
        return image
    }
    
    // Save text
    func saveText(text: String, path: String) -> Bool {
        var error: NSError? = nil
        let status = text.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        if !status { //status == false {
            println("Error saving file at path: \(path) with error: \(error?.localizedDescription)")
        }
        return status
    }
    
    // Load text
    func loadTextFromPath(path: String) -> String? {
        var error: NSError? = nil
        let text = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: &error)
        if text == nil {
            println("Error loading text from path: \(path) error: \(error?.localizedDescription)")
        }
        return text
    }
    
    
    //Keyboard moves screen upward
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    func keyboardWillShow(notification: NSNotification) {
        if self.imageView.image != nil {
            self.imageView.alpha = 0.0
        }
        self.view.frame.origin.y -= self.getKeyboardHeight(notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        if self.imageView.image != nil {
            self.imageView.alpha = 1.0
        }
        self.view.frame.origin.y += self.getKeyboardHeight(notification)
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        return keyboardSize.CGRectValue().height
    }



}

