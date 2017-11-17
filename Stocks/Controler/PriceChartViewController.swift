//
//  PriceChartViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 10..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit
import Charts

class PriceChartViewController: UIViewController {
    // MARK: - Model
    var data = [Date: Double]() { didSet { updateChartViewFromModel() } }
    
    // MARK: - Instance properties
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private var chart: LineChartView! {
        didSet {
            chart.isUserInteractionEnabled = false
            
            chart.chartDescription?.enabled = false
            chart.legend.enabled = false
            chart.noDataText = NSLocalizedString("Error retrieving chart.", comment: "")
            chart.noDataFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            
            chart.xAxis.valueFormatter = DateValueFormatter()
            chart.xAxis.labelCount = Constants.Chart.dateLabelCount
            chart.xAxis.labelPosition = .bottom
            
            chart.leftAxis.enabled = false
            chart.rightAxis.labelCount = Constants.Chart.priceLabelCount
            chart.rightAxis.labelPosition = .outsideChart
        }
    }
    
    private let stockQueryService = StockQueryService()
    private var requestToken: RequestToken?
    
    // MARK: - Instance methods
    func setData(from stock: Stock) {
        data.removeAll()

        if let lastSet = stock.historicalPrices.lastSet?.timeIntervalSinceNow, lastSet > (-Constants.Stock.articlesValidFor) {
            for price in stock.historicalPrices.entries {
                data[price.date] = price.open
            }
        }
        else {
            requestToken?.cancel()
            spinner?.startAnimating()
            
            requestToken = stockQueryService.getDailyPrices(forSymbol: stock.symbol) { [weak self] result in
                self?.spinner.stopAnimating()
                
                switch result {
                case Result.Success(let newDailyPrices):
                    stock.historicalPrices.entries = newDailyPrices
                    
                    for price in newDailyPrices {
                        self?.data[price.date] = price.open
                    }
                case Result.Failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateChartViewFromModel() {
        if data.isEmpty {
            chart.data = nil
            chart.notifyDataSetChanged()
            return
        }
        
        var lineChartEntry  = [ChartDataEntry]()
        
        for price in data.sorted(by: { $0.key < $1.key }) {
            let value = ChartDataEntry(x: price.key.timeIntervalSince1970, y: price.value)
            lineChartEntry.append(value)
        }
        
        let priceLineDataSet: LineChartDataSet = {
            let gradient: CGGradient! = {
                let gradientColors = [UIColor.black.cgColor, UIColor.clear.cgColor] as CFArray
                let colorLocations:[CGFloat] = [1.0, 0.0]
                
                return CGGradient.init(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: gradientColors,
                    locations: colorLocations
                )
            }()
            
            let line = LineChartDataSet(values: lineChartEntry, label: nil)
            line.colors = [.black]
            line.drawCirclesEnabled = false
            line.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
            line.drawFilledEnabled = true
            
            return line
        }()

        let chartData = LineChartData()
        chartData.addDataSet(priceLineDataSet)
        chartData.setDrawValues(false)

        chart.data = chartData
    } 
}

// MARK: - DateValueFormatter
class DateValueFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formater = DateFormatter()
        formater.dateStyle = .short
        formater.timeStyle = .none
        
        return formater.string(from: Date(timeIntervalSince1970: value))
    }
}
