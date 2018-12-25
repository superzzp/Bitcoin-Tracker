//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var currentCurrencyLabel = ""
    var finalURL = ""
    let bitcoinData = BitcoinDataModel()

    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var bitcoinPriceValueLabel: UILabel!
    
    @IBOutlet weak var priceChangeValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
       
    }

    
    //TODO: Place your 3 UIPickerView delegate methods here
    
    //set the number of column in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //set the number of rows in the picker, which is equal to the number of elements in the currencyArray
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    //fill the picker row titles
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    //method get called everytime the picker gets selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let symbol: String = "/BTC" + currencyArray[row]
        currentCurrencyLabel = bitcoinData.currencyLabel[row]
        finalURL = baseURL + symbol
        print(finalURL)
        // let symbol_set: String = "global"
        startGetPrice();
    }
    
    func startGetPrice() {
        //let param: [String:String] = ["symbol":symbol]
        getBitcoinData(url: finalURL)
    }
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getBitcoinData(url: String) {
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {

                    print("Sucess! Got the bitcoin data")
                    let bitcoinJSON : JSON = JSON(response.result.value!)

                    self.updateBitcoinData(json: bitcoinJSON)

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
                }
            }

    }

    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateBitcoinData(json : JSON) {

        if let averagesPrice = json["averages"]["day"].double {

        
//        weatherData.city = json["name"].stringValue
//        weatherData.condition = json["weather"][0]["id"].intValue
//        weatherData.weatherIconName =    weatherData.updateWeatherIcon(condition: weatherData.condition)
        bitcoinData.dailyAveragesPrice = averagesPrice
        bitcoinData.dailyPriceChanges = json["changes"]["price"]["day"].double!
        updateUIWithBitcoinData()
        }else{
            bitcoinPriceLabel.text = "Error updating bitcoin data"
        }
    }
    

    func updateUIWithBitcoinData(){
        
        bitcoinPriceValueLabel.text = "\(currentCurrencyLabel)\(bitcoinData.dailyAveragesPrice)"
        if (bitcoinData.dailyPriceChanges <= 0.0) {
            priceChangeValueLabel.textColor = UIColor.red
        }else{
            priceChangeValueLabel.textColor
                = UIColor.green
        }
        priceChangeValueLabel.text = "\(bitcoinData.dailyPriceChanges)"
        
    }
}

