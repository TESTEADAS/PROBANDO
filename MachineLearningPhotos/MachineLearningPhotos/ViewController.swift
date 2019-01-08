//
//  ViewController.swift
//  MachineLearningPhotos
//
//  Created by Brian Morales on 1/4/19.
//  Copyright © 2019 Brian Morales. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detectarImagenes()
    }
    
    //variables
    
    //outlet
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    
    //actions
    @IBAction func tomarFoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }else{
            print("No se pudo acceder a la camara")
        }
    }
    
    @IBAction func selecFoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }else{
            print("No se pudo acceder a Fotos")
        }
    }
    
    //funciones
    func detectarImagenes () {
        
        dataLabel.text = "Cargando..."
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            print("Ocurrio un error. No se pudo crear modelo")
            return
        }
        
        let peticion = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let resultados = request.results as? [VNClassificationObservation],
                let primerResultado = resultados.first else {
                    print("No se encontraron resultados")
                    return
            }
            DispatchQueue.main.async {
                self.dataLabel.text = "\(primerResultado.identifier)"
            }
        }
        
        guard let ciimageForUse = CIImage(image: self.dataImage.image!) else {
            print("No se creo imagen")
            return
        }
        
        //Correr peticion
        let handler = VNImageRequestHandler(ciImage: ciimageForUse)
        
        DispatchQueue.global().async {
            do{
                try handler.perform([peticion])
            }catch{
                print(error.localizedDescription)
            }
        }
        
    }
    
    //funciones de sistema
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.dataImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        detectarImagenes()
    }

}

