//
//  HomeViewController.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 23/12/2020.
//

import UIKit
import SVProgressHUD
import DropDown

class HomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFromCurrency: UITextField!
    @IBOutlet weak var txtToCurrency: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtResult: UITextField!
    
    var currencyList: NSArray!
    var currencyDisplayList: NSArray!
    var selectedFromCurrency: Currency!
    var selectedToCurrency: Currency!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyList = NSArray()
        currencyDisplayList = NSArray()
        setupInterface()
        getCurrencyList()
        
    }
    
    // MARK: - Helper
    func setupInterface(){
        
        txtToCurrency.delegate = self
        txtFromCurrency.delegate = self
        txtAmount.delegate = self
        txtResult.delegate = self
        addDoneButtonOnKeyboard()
        
    }
    
    func getCurrencyList(){
        
        if !Connectivity.isConnectedToInternet() {
            Utility.showAlertWith(Title: "Message", AndMessage: "Check internet connection!", On: self) {
            }
            return
        }
        
        SVProgressHUD.show()
        APIManager.shareManager.getCurrencyList { [self] (json, NetworkStatus) in
            SVProgressHUD.dismiss()
            let status = json["success"].boolValue
            if (status){
                let list = NSMutableArray()
                let displayList = NSMutableArray()
                let results = json["currencies"].dictionaryValue
                for strKey in results.keys{
                    let objCurrency = Currency()
                    objCurrency.code = strKey
                    objCurrency.strDescription = results[strKey]?.stringValue ?? ""
                    list.add(objCurrency)
                }
                currencyList = list.copy() as! NSArray
                currencyList = currencyList.sorted(by: { ($0 as! Currency).strDescription! < ($1 as! Currency).strDescription! }) as NSArray
                for obj in currencyList{
                    let objCurrency = obj as! Currency
                    let str = "\(objCurrency.code ?? "") - \(objCurrency.strDescription ?? "")"
                    displayList.add(str)
                }
                currencyDisplayList = displayList.copy() as! NSArray
            }
            else{
                let result = json["error"].dictionaryValue
                let errDes = result["info"]?.stringValue ?? "ERR"
                Utility.showAlertWith(Title: "Error", AndMessage: errDes, On: self) {
                }
            }
        }
    }
    
    func getExchangeRate(){
        
        if !Connectivity.isConnectedToInternet() {
            Utility.showAlertWith(Title: "Message", AndMessage: "Check internet connection!", On: self) {
            }
            return
        }
        let strAmount = txtAmount.text ?? ""
        SVProgressHUD.show()
        DataManager.sharedManager.deleteExchangeRateWith(code: selectedFromCurrency.code!)
        DataManager.sharedManager.deleteExchangeRateWith(code: selectedToCurrency.code!)
        
        APIManager.shareManager.getExchangeRate(fromCurrency: selectedFromCurrency.code, toCurrency: selectedToCurrency.code) { [self] (json, NetworkStatus) in
            SVProgressHUD.dismiss()
            let status = json["success"].boolValue
            if (status){
                
                let source = json["source"].stringValue
                let rates = json["quotes"].dictionaryValue
                
                var strKey = "\(source)\(selectedFromCurrency.code ?? "")"
                let fromRate = rates[strKey]?.doubleValue ?? 0.0
                DataManager.sharedManager.saveExchangeRate(code: selectedFromCurrency.code, desc: selectedFromCurrency.strDescription, source: source, rate: fromRate)
                
                strKey = "\(source)\(selectedToCurrency.code ?? "")"
                let toRate = rates[strKey]?.doubleValue ?? 0.0
                
                DataManager.sharedManager.saveExchangeRate(code: selectedToCurrency.code, desc: selectedToCurrency.strDescription, source: source, rate: toRate)
                
                let result = (Double(strAmount)! / fromRate) * toRate
                txtResult.text = String(format: "%f", result)
                
               
            }else{
                
                let result = json["error"].dictionaryValue
                let errDes = result["info"]?.stringValue ?? "ERR"
                Utility.showAlertWith(Title: "Error", AndMessage: errDes, On: self) {
                }
            }
        }
    }
    
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            txtAmount.inputAccessoryView = doneToolbar
        }

        @objc func doneButtonAction(){
            txtAmount.resignFirstResponder()
        }
    
    // MARK: - Action
    
    @IBAction func onClickExchangeRate(_ sender: UIButton) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExchangeRateViewController")as! ExchangeRateViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickCalculate(_ sender: UIButton) {
        
        txtAmount.resignFirstResponder()
        
        let strAmount = txtAmount.text ?? ""
        if (strAmount.count == 0){
            Utility.showAlertWith(Title: "Message", AndMessage: "Enter amount.", On: self) {
            }
            return
        }
        if (selectedFromCurrency == nil || selectedToCurrency == nil){
            Utility.showAlertWith(Title: "Message", AndMessage: "Select currency.", On: self) {
            }
            return
        }
        
        let list = DataManager.sharedManager.fetchAllExchangeRates()
        let fromFiltered = list!.filter{ ($0 as! ExchangeRate).code! == selectedFromCurrency.code } as NSArray
        let toFiltered = list!.filter{ ($0 as! ExchangeRate).code! == selectedToCurrency.code } as NSArray
        if (fromFiltered.count>0 && toFiltered.count>0){
            
            let fromExchangeRate = fromFiltered.firstObject as! ExchangeRate
            let toExchangeRate = toFiltered.firstObject as! ExchangeRate
            
            let time1 = abs(Int(fromExchangeRate.update_date!.timeIntervalSinceNow))/60
            let time2 = abs(Int(fromExchangeRate.update_date!.timeIntervalSinceNow))/60
            print("timeinterval \(time1): \(time2)")
            if (time1 < 30 && time2 < 30){
                let result = (Double(strAmount)! / fromExchangeRate.rate) * toExchangeRate.rate
                txtResult.text = String(format: "%f", result)
            }
            else{
                getExchangeRate()
            }
        }
        else{
            getExchangeRate()
        }
   
    }
    
    // MARK: - delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ( textField == txtAmount){
            return true
        }
        
        if ( textField == txtResult){
            return false
        }
        
        txtAmount.resignFirstResponder()
        let dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.dataSource = currencyDisplayList as! [String]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            textField.text = item
            let selectedCurrency = currencyList.object(at: index) as! Currency
            if (textField == txtFromCurrency){
                selectedFromCurrency = selectedCurrency
            }
            if (textField == txtToCurrency){
                selectedToCurrency = selectedCurrency
            }
        }
        dropDown.width = textField.frame.width
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.show()
        
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        txtAmount.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countdots = (textField.text?.components(separatedBy: ".").count)! - 1

        if countdots > 0 && string == "."
        {
            return false
        }
        return true
    }
   
   
    
}

