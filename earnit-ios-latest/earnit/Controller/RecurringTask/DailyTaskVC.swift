//
//  DailyTaskVC.swift
//  earnit
//
//  Created by macpro on 11/22/18.
//  Copyright © 2018 Mobile-Di. All rights reserved.
//
protocol DailyDelegate: class {
    
    func saveDailyData(dic: NSDictionary)
}

import UIKit

class DailyTaskVC: UIViewController {
    weak var delegate: DailyDelegate?
    @IBOutlet var repeatsField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.repeatTaskDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton,doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        repeatsField?.inputAccessoryView = pickerToolBar

        // Do any additional setup after loading the view.
    }
    
    func repeatTaskDoneButtonClicked() {
        repeatsField?.resignFirstResponder()
    }
    
    @IBAction func cancelBtnTapped() {
        
        
        
        self.dismiss(animated: true) {
            
        }
        
    }
    @IBAction func saveBtnTapped() {
        self.view.endEditing(true)
        if self.validation() == true {
            
            
            if let text = repeatsField.text {
                let dic = ["repeats":text]
                
                self.delegate?.saveDailyData(dic: dic as NSDictionary)
                self.dismiss(animated: true) {
                    
                }
            }
        }
        
    }
    
    
    func validation() -> Bool{
        
        if (repeatsField.text?.count)! < 1 {
            self.view.makeToast("Insert correct data")
            return false
        }
        else {
            return true
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
