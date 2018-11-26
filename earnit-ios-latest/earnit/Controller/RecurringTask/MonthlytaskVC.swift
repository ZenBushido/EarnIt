//
//  MonthlytaskVC.swift
//  earnit
//
//  Created by macpro on 11/22/18.
//  Copyright © 2018 Mobile-Di. All rights reserved.
//


protocol MonthlyDelegate: class {
    
    func saveData(dic: NSDictionary)
}

import UIKit

class MonthlytaskVC: UIViewController {
    weak var delegate: MonthlyDelegate?
    @IBOutlet weak var Collecview: UICollectionView!
    @IBOutlet weak var btn_each: UIButton!
    @IBOutlet weak var btn_onthe: UIButton!
    @IBOutlet var repeatsField: UITextField!
     @IBOutlet var numField: UITextField!
     @IBOutlet var daysField: UITextField!
     var activeField:UITextField?
    var numPicker = UIPickerView()
    var daysPicker = UIPickerView()
    
    let selected_color = UIColor(red: 218.0/255.0, green: 71.0/255.0, blue: 156.0/255.0, alpha: 1)
    let dataArray = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    var dataSelectedArray: [String] = []
    
    let numTasks = ["First","Second","Third","Fourth","Fifth","Last"]
    let daysTasks = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    @IBAction func cancelBtnTapped() {
        
        
        
        self.dismiss(animated: true) {
            
        }
        
    }
    @IBAction func saveBtnTapped() {
         self.view.endEditing(true)
        if self.validation() == true {
        
             var onTheNum = ""
             var onTheDay = ""
            if self.btn_onthe.isSelected == true {
                onTheNum  = self.numField.text!
                onTheDay  = self.daysField.text!
            }
            
            if let text = repeatsField.text {
                let dic = ["repeats":text,"dates": dataSelectedArray,"onTheNum":onTheNum,"onTheDay": onTheDay] as [String : Any]
            
            self.delegate?.saveData(dic: dic as NSDictionary)
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
       else if (dataSelectedArray.count) < 1 && self.btn_each.isEnabled == true {
            self.view.makeToast("Insert correct data")
            return false
        }
        else {
              return true
        }
        
    }

    
    func repeatTaskDoneButtonClicked() {
         repeatsField?.resignFirstResponder()
        self.numField.resignFirstResponder()
         self.daysField.resignFirstResponder()  
    }
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
        btn_each.isSelected =  true
        self.numField.isEnabled =  false
        self.daysField.isEnabled =  false
        
        // Do any additional setup after loading the view.
    }
    @IBAction func eachOntheButtonTapped(btn:UIButton) {
        
        if btn == btn_each {
            
            btn_each.isSelected = true
            btn_onthe.isSelected = false
            
            self.numField.isEnabled =  false
            self.daysField.isEnabled =  false
        }
        else if btn == btn_onthe {
            
            for strnum in dataSelectedArray {
                
                if let num = Int(strnum) {
                
                let newTag = num + 100
                
                if let founbutton = view.viewWithTag(newTag) as? UIButton  {
                  //  let color : UIColor = (founbutton.isSelected == true ? .clear : selected_color)
                    
                    founbutton.isSelected = false
                    
                    
                    founbutton.backgroundColor = .clear
                 }
                }
            }
            
            dataSelectedArray.removeAll()
            btn_each.isSelected =  false
            btn_onthe.isSelected = true
            self.numField.isEnabled =  true
            self.daysField.isEnabled = true
            //self.Collecview.reloadData()
            
        }
        
        
    }
    
    func daysPickerViewSetup()  {
        //UIPickerView
        // goalPicker = UIPickerView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:216))
        daysPicker.dataSource = self
        daysPicker.delegate = self
        daysPicker.backgroundColor = UIColor.white
        
        //ToolBar
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        
        //Adding ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.repeatTaskDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton,doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        daysField?.inputAccessoryView = pickerToolBar
        daysField?.inputView = daysPicker
        daysPicker.selectRow(daysTasks.index(of: daysField.text!)!, inComponent: 0, animated: false)
        
        
    }
    
    func numPickerViewSetup()  {
        //UIPickerView
        // goalPicker = UIPickerView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:216))
        numPicker.dataSource = self
        numPicker.delegate = self
        numPicker.backgroundColor = UIColor.white
        
        //ToolBar
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        
        //Adding ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.repeatTaskDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton,doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        numField?.inputAccessoryView = pickerToolBar
        numField?.inputView = numPicker
        numPicker.selectRow(numTasks.index(of: numField.text!)!, inComponent: 0, animated: false)
    
    
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

extension MonthlytaskVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        if textField == numField  {
            self.numPickerViewSetup()
        }
        else if textField == daysField  {
            self.daysPickerViewSetup()
        }
        return true
    }
    
      // MARK: collectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "MonthlyCell"
        
        let cell =   self.Collecview.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MonthlyCell
        
        cell.button_date.tag = indexPath.row + 1 + 100
        
        cell.label_date.text = dataArray[indexPath.row]

        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.btn_each.isSelected == true {
        
        let newTag = indexPath.row + 1 + 100
        
        if let founbutton = view.viewWithTag(newTag) as? UIButton  {
            
            let str = dataArray[indexPath.row]
            
            if dataSelectedArray.contains(str) {
                dataSelectedArray.remove(element: str)
            }
            else {
                dataSelectedArray.append(str)
            }
            
            let color : UIColor = (founbutton.isSelected == true ? .clear : selected_color)
            
            founbutton.isSelected = !founbutton.isSelected
            
            
            founbutton.backgroundColor = color
            
            
        }
        }
        
    }
    
    //MARK: -UIPickerView Datasource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeField == numField {
            return self.numTasks.count
        }
        else  {
            return self.daysTasks.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeField == numField {
            return self.numTasks[row]
        }
        else  {
            return self.daysTasks[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //repeatTasks
        if activeField == numField {
            self.numField.text = numTasks[row]
            
        }
        else  {
            
            self.daysField.text = self.daysTasks[row]
        }
    }
    
}

    class MonthlyCell: UICollectionViewCell {
        @IBOutlet weak var label_date:UILabel!
        @IBOutlet weak var button_date:UIButton!
}

extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.index(of: element) {
            self.remove(at: i)
        }
    }
}
