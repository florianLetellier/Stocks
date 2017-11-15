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
    public var data = [Date: Double]() { didSet { updateChartViewFromModel() } }
    
    // MARK: - Instance properties
    @IBOutlet var chart: LineChartView! {
        didSet {
            chart.isUserInteractionEnabled = false
            
            chart.chartDescription?.enabled = false
            chart.legend.enabled = false
            chart.noDataText = NSLocalizedString("Error retrieving chart.", comment: "")
            chart.noDataFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            
            chart.xAxis.valueFormatter = DateValueFormatter()
            chart.xAxis.labelCount = 4
            chart.xAxis.labelPosition = .bottom
            
            chart.leftAxis.enabled = false
            chart.rightAxis.labelCount = 2
            chart.rightAxis.labelPosition = .outsideChart
        }
    }
    
    // MARK: - Instance methods
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

// MARK: - PriceChartViewController extension
extension PriceChartViewController {
    func setData(from dailyPrices:[Stock.dailyPrice]) {
        data.removeAll()
        
        for price in dailyPrices {
            data[price.date] = price.open
        }
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
