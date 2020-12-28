//
//  ExchangeRateViewController.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 25/12/2020.
//

import UIKit
import SVProgressHUD

class ExchangeRateViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var exchangeList = NSArray()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.delegate = self
        tblView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.title = "Exchange Rates"
        exchangeList = DataManager.sharedManager.fetchAllExchangeRates() as! NSArray
        tblView.reloadData()
        tblView.sizeToFit()
    }
    
    // MARK: - Helper
    
}

extension ExchangeRateViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return exchangeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) 
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.tag = indexPath.row
        
        let objExc = exchangeList.object(at: indexPath.row) as! ExchangeRate
        let lbl1 = cell.contentView.viewWithTag(10) as! UILabel
        let lbl2 = cell.contentView.viewWithTag(20) as! UILabel
        let lbl3 = cell.contentView.viewWithTag(30) as! UILabel
        
        lbl1.text = objExc.code
        lbl2.text = String(format: "%f", objExc.rate)
        lbl3.text = Utility.displayDateFrom(date: objExc.update_date!, format:"dd/MM/yyyy")
        
        return cell
    }
    
    
}
