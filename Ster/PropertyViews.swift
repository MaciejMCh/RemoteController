//
//  PropertyViews.swift
//  Ster
//
//  Created by Maciej Chmielewski on 17.05.2016.
//  Copyright © 2016 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class PropertyTypePopupButton: NSPopUpButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        removeAllItems()
        addItemWithTitle(PropertyType.String.rawValue)
        addItemWithTitle(PropertyType.Bool.rawValue)
        addItemWithTitle(PropertyType.Number.rawValue)
    }
}

class PropertyNameCell: NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var nameTextField: NSTextField!
    weak var delegate: PropertiesViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.delegate = self
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        delegate.nameChanged(self, name: nameTextField.stringValue)
        return true
    }
}

class PropertyTypeCell: NSTableCellView {
    @IBOutlet weak var typePopUpButton: NSPopUpButton!
    weak var delegate: PropertiesViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typePopUpButton.target = self
        typePopUpButton.action = #selector(changed)
        
    }
    
    func changed() {
        delegate.typeChanged(self, type: PropertyType(rawValue: typePopUpButton.selectedItem!.title)!)
    }
}

class PropertyValueCell: NSTableCellView {
    @IBOutlet weak var valueTextField: NSTextField!
    @IBOutlet weak var boolValueCheck: NSButton!
    weak var delegate: PropertiesViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        boolValueCheck.target = self
        boolValueCheck.action = #selector(boolChanged)
        
        valueTextField.target = self
        valueTextField.action = #selector(textFieldChanged)
    }
    
    func boolChanged() {
        delegate.valueChanged(self, value: boolValueCheck.state == 1 ? true : false)
    }
    
    func textFieldChanged() {
        delegate.valueChanged(self, value: valueTextField.stringValue)
    }
}

class DeleteCell: NSTableCellView {
    @IBOutlet weak var deleteButton: NSButton!
    weak var delegate: PropertiesViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.target = self
        deleteButton.action = #selector(delete)
    }
    
    func delete() {
        delegate.delete(self)
    }
}

