//
//  DetailsVC.swift
//  ArtBook
//
//  Created by Faruk Yaşar on 29.11.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var choosenPainting = ""
    var choosenPaintingİd : UUID?
    
    
       

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenPainting != "" {
            //Core Data dan veri çekme ve bağlanma
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            //Burada Adı ... olan veri tabanına bağlanıyoruz
            let FetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = choosenPaintingİd?.uuidString
            FetchRequest.predicate = NSPredicate(format: "id=%@", idString!)
            FetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(FetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                            
                        
                    }
                }
            }
            catch{
                print("error")
            }
             
        }else{
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        

        //Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTabRecognizer = UITapGestureRecognizer(target: self, action: #selector(selecImage))
        imageView.addGestureRecognizer(imageTabRecognizer)
    }
    
    @objc func selecImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
        
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = (appDelegate?.persistentContainer.viewContext)!
        
        let newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attiributes
        
        newPaintings.setValue(nameText.text!, forKey: "name")
        newPaintings.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPaintings.setValue(year, forKey: "year")
        }
        newPaintings.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPaintings.setValue(data, forKey: "image")
        
        do{
            try  context.save()
            print("saved")
        }catch{
            print("error")
        }
       
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        //Bir önceki viewcontroller a gitmek için
        self.navigationController?.popViewController(animated: true)
        
    }
    
   

}
