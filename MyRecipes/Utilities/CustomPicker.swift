//
//  CustomPicker.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

//Creating Protocol
protocol CustomPickerDelegate: class
{
    func itemPicked(item: AnyObject)
    func pickerCancelled()
}

enum CustomPickerType : Int
{
    case e_PickerType_String = 1,
    e_PickerType_Date
    
}

class CustomPicker: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: - Protocol Declaration
    weak var delegate: CustomPickerDelegate? = nil
    
    @IBOutlet weak var viewPickerBackground : UIView!
    
    //MARK: - Properties Declaration
    var customPicker: UIPickerView!
    var customDatePicker : UIDatePicker!
    
    var totalComponents: Int!
    var arrayComponent = [String]()
    
    var currentPickerType : CustomPickerType = .e_PickerType_String
    
    let screenFrame = UIScreen.main.bounds
    
    //MARK: - UIViewController Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadCustomPicker(pickerType : CustomPickerType)
    {
        self.removePickerViews()
        currentPickerType = pickerType
        
        switch pickerType
        {
        case .e_PickerType_String:
            configStringPicker()
            
        case .e_PickerType_Date:
            configDateTimePicker()
            
        }
    }
    
    func removePickerViews()
    {
        let pickerViews = viewPickerBackground.subviews
        for view in pickerViews
        {
            view.removeFromSuperview()
        }
    }
    
    func configStringPicker()
    {
        customPicker = UIPickerView(frame: CGRect(x: 0.0, y: 44.0, width: screenFrame.size.width, height: 216.0))
        customPicker.delegate = self
        customPicker.dataSource = self
        
        let pickerToolbar = getPickerToolbar()
        viewPickerBackground.addSubview(pickerToolbar)
        viewPickerBackground.addSubview(customPicker)
    }
    
    func configDateTimePicker()
    {
        customDatePicker = UIDatePicker(frame: CGRect(x: 0.0, y: 44.0, width: screenFrame.size.width, height: 216.0))
        
        let pickerToolbar = getPickerToolbar()
        viewPickerBackground.addSubview(pickerToolbar)
        viewPickerBackground.addSubview(customDatePicker)
    }
    
    func getPickerToolbar() -> UIToolbar
    {
        let pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenFrame.size.width, height: 44))
        pickerToolbar.barTintColor = UIColor(hex: "#035F8A")
        
        let cancelButton = UIBarButtonItem(title: IDENTIFIERS.CANCEL, style: .done, target: self, action: #selector(cancelButtonAction(_:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction(_:)))
        let flexibespace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        cancelButton.tintColor  = UIColor.blue
        doneButton.tintColor    = UIColor.blue
        
        let arrayButtons = [cancelButton,flexibespace,doneButton]
        pickerToolbar.setItems(arrayButtons, animated: true)
        
        return pickerToolbar
    }
    
    //MARK: - IBAction methods
    @objc func cancelButtonAction(_ sender: Any)
    {
        if self.delegate != nil
        {
            self.delegate?.pickerCancelled()
        }
    }
    
    @objc func doneButtonAction(_ sender: Any)
    {
        var pickerValue : Any! = nil
        
        switch currentPickerType
        {
        case .e_PickerType_String:
            
            if customPicker != nil
            {
                let selectedRow = customPicker.selectedRow(inComponent: 0)
                pickerValue = arrayComponent[selectedRow]
                
                IDENTIFIERS.LAST_SELECTED_INDEX_N_PICKER = selectedRow
            }
            
        case .e_PickerType_Date:
            let pickedDate = customDatePicker.date
            pickerValue = pickedDate
            
        }
        
        if pickerValue != nil && self.delegate != nil
        {
            self.delegate?.itemPicked(item: pickerValue as AnyObject)
        }
    }
    
    //MARK: - String Picker Delegate
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return totalComponents
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayComponent.count
    }
    
    //MARK: - UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return arrayComponent[row]
    }
}
