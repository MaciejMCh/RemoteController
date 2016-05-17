//
//  NumberPicker.swift
//  Ster
//
//  Created by Maciej Chmielewski on 17.05.2016.
//  Copyright © 2016 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class NumberPickerController: NSViewController {
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var valueLabel: NSTextField!
    
    weak var delegate: PropertiesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.target = self
        slider.action = #selector(valueChanged)
    }
    
    func valueChanged() {
        let sliderY = view.window!.frame.origin.y + CGRectGetMidY(slider.frame)
        let mouseY = NSEvent.mouseLocation().y
        let diff = abs(sliderY - mouseY)
        let value = slider.floatValue
        let fixedValue = Float(diff) * 0.2 * value  * value
        valueLabel.stringValue = "\(fixedValue)"
        delegate.valueChanged(fixedValue)
    }
}