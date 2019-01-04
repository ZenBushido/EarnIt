//
//  WeeklyTaskVC.swift
//  earnit
//
//  Created by macpro on 11/22/18.
//  Copyright © 2018 Mobile-Di. All rights reserved.
//
protocol WeeklyDelegate: class {
    
    func saveWeaklyData(dic: NSDictionary)
}

import UIKit

class WeeklyTaskVC: UIViewController {
     let selected_color = UIColor(red: 115.0/255.0, green: 244.0/255.0, blue: 64.0/255.0, alpha: 1)
   // let selected_color = UIColor(red: 218.0/255.0, green: 71.0/255.0, blue: 156.0/255.0, alpha: 1)
    weak var delegate: WeeklyDelegate?
    @IBOutlet weak var Collecview: UICollectionView!
    @IBOutlet var repeatsField: UITextField!
    var dataSelectedArray: [String] = []
      let dataArray = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
      let daysTasks = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
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
                let dic = ["repeats":text,"selectedDay":dataSelectedArray] as [String : Any]
                
                self.delegate?.saveWeaklyData(dic: dic as NSDictionary)
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
        else if (dataSelectedArray.count) < 1{
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

extension WeeklyTaskVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    // MARK: collectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "WeaklyCell"
        
        let cell =   self.Collecview.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! WeaklyCell
        
        cell.button_date.tag = indexPath.row + 1 + 100
        cell.label_date.text = dataArray[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
      //  if self.btn_each.isSelected == true {
           // selectedDay = self.daysTasks[indexPath.row]
        
            let newTag = indexPath.row + 1 + 100
        
        

            if let founbutton = view.viewWithTag(newTag) as? UIButton {
                
                let str = daysTasks[indexPath.row]
                
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

class WeaklyCell: UICollectionViewCell {
    @IBOutlet weak var label_date:UILabel!
    @IBOutlet weak var button_date:UIButton!
}
