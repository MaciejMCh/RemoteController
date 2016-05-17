//
//  PropertiesModels.swift
//  Ster
//
//  Created by Maciej Chmielewski on 17.05.2016.
//  Copyright © 2016 Maciej Chmielewski. All rights reserved.
//

import Foundation

enum PropertyType: String {
    case String
    case Bool
    case Number
    
    func zeroValue() -> AnyObject {
        switch self {
        case .String: return ""
        case .Bool: return false
        case .Number: return 0
        }
    }
}

struct Property {
    var name: String
    var type: PropertyType
    var value: AnyObject
    
    func toJson() -> [String: AnyObject] {
        return ["name": name, "type": type.rawValue, "value": value]
    }
    
    static func fromJson(json: [String: AnyObject]) -> Property {
        return Property(name: json["name"] as! String, type: PropertyType(rawValue: json["type"] as! String)!, value: json["value"]!)
    }
}

class Properties {
    static let sharedInstance = Properties()
    var properties: [Property]
    
    init() {
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("properties")
        guard let string = NSUserDefaults.standardUserDefaults().stringForKey("properties") else {
            self.properties = []
            return
        }
        guard let json = string.parseJSONString as? [String: AnyObject] else {
            self.properties = []
            return
        }
        let propertiesJsonArray = json["properties"] as! Array<AnyObject>
        
        self.properties = []
        for property in propertiesJsonArray {
            if let propertyJson = property as? [String: AnyObject] {
                self.properties.append(Property.fromJson(propertyJson))
            }
        }
    }
    
    func save() {
        var jsonArray = Array<Dictionary<String, AnyObject>>()
        for property in properties {
            jsonArray.append(property.toJson())
        }
        let json = ["properties": jsonArray]
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let string = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSUserDefaults.standardUserDefaults().setObject(string, forKey: "properties")
        } catch {
            
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func new() {
        properties.append(Property(name: "", type: .String, value: ""))
        save()
    }
    
    func updateName(index: Int, name: String) {
        properties[index].name = name
        save()
    }
    
    func changeType(index: Int, type: PropertyType) {
        properties[index].type = type
        properties[index].value = type.zeroValue()
        save()
    }
    
    func changeValue(index: Int, var value: AnyObject) {
        let property = properties[index]
        
        if property.type == .Number {
            value = Float(value as! String)!
        }
        
        properties[index].value = value
        save()
    }
    
    func delete(index: Int) {
        properties.removeAtIndex(index)
        save()
    }
}

extension String
{
    var parseJSONString: AnyObject?
    {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        if let jsonData = data
        {
            // Will return an object or nil if JSON decoding fails
            do
            {
                let message = try NSJSONSerialization.JSONObjectWithData(jsonData, options:.MutableContainers)
                return message
                if let jsonResult = message as? NSMutableArray
                {
                    print(jsonResult)
                    
                    return jsonResult //Will return the json array output
                }
                else
                {
                    return nil
                }
            }
            catch let error as NSError
            {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else
        {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}