//
//  PropertiesViewController.swift
//  Ster
//
//  Created by Maciej Chmielewski on 17.05.2016.
//  Copyright © 2016 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class PropertiesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return Properties.sharedInstance.properties.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return nil
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        let property = Properties.sharedInstance.properties[row]
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "NameCellID"
        } else if tableColumn == tableView.tableColumns[1] {
            cellIdentifier = "TypeCellID"
        } else if tableColumn == tableView.tableColumns[2] {
            cellIdentifier = "ValueCellID"
        } else if tableColumn == tableView.tableColumns[3] {
            cellIdentifier = "DeleteCellID"
        }
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            if let nameCell = cell as? PropertyNameCell {
                nameCell.delegate = self
                nameCell.nameTextField.stringValue = property.name
            }
            if let typeCell = cell as? PropertyTypeCell {
                typeCell.delegate = self
                typeCell.typePopUpButton.selectItemWithTitle(property.type.rawValue)
            }
            if let valueCell = cell as? PropertyValueCell {
                valueCell.delegate = self
                valueCell.boolValueCheck.hidden = property.type != .Bool
                valueCell.valueTextField.hidden = property.type == .Bool
                
                switch property.type {
                case .Bool: valueCell.boolValueCheck.state = (property.value as! Bool) ? 1 : 0
                case .String: valueCell.valueTextField.stringValue = property.value as! String
                case .Number: valueCell.valueTextField.stringValue = "\((property.value as! NSNumber).floatValue)"
                }
            }
            if let deleteCell = cell as? DeleteCell {
                deleteCell.delegate = self
            }
            return cell
        }
        return nil
    }
    
    func nameChanged(cell: NSTableCellView, name: String) {
        Properties.sharedInstance.updateName(self.tableView.rowForView(cell), name: name)
    }
    
    func typeChanged(cell: NSTableCellView, type: PropertyType) {
        Properties.sharedInstance.changeType(self.tableView.rowForView(cell), type: type)
        self.tableView.reloadData()
    }
    
    func valueChanged(cell: NSTableCellView, value: AnyObject) {
        Properties.sharedInstance.changeValue(self.tableView.rowForView(cell), value: value)
        self.tableView.reloadData()
    }
    
    func delete(cell: NSTableCellView) {
        Properties.sharedInstance.delete(self.tableView.rowForView(cell))
        self.tableView.reloadData()
    }
    
    @IBAction func addAction(sender: AnyObject?) {
        Properties.sharedInstance.new()
        tableView.reloadData()
    }
}
