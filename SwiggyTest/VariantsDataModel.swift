//
//  VariantsDataModel.swift
//  SwiggyTest
//
//  Created by Kushagra Gupta on 29/07/17.
//  Copyright © 2017 Kushagra Gupta. All rights reserved.
//

import Foundation

class Variation{
    var id:String = ""
    var name:String = ""
    var price:Double = 0.0
    var defaultSelection:Bool = false
    var inStock:Bool = true
    var isVeg:Bool = false
    var isSelected:Bool = false
    
    convenience init(_ json:[AnyHashable: Any]){
        self.init()
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        price = json["price"] as? Double ?? 0.0
        defaultSelection = json["default"] as? Bool ?? false
        inStock = json["inStock"] as? Bool ?? true
        isVeg = json["isVeg"] as? Bool ?? false
        isSelected = defaultSelection
    }
}

class VariantGroup{
    var groupId:String = ""
    var name:String = ""
    var variations:[Variation] = []
    
    convenience init(_ json:[AnyHashable: Any]){
        self.init()
        groupId = json["group_id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        if let variationsJSON = json["variations"] as? [[AnyHashable: Any]]{
            for variationJSON in variationsJSON{
                variations.append(Variation(variationJSON))
            }
        }
    }
    
    func getDefaultVariation() -> VariationGroupMap?{
        for variation in variations where variation.defaultSelection{
            return VariationGroupMap.initWith(groupId: groupId, variationID: variation.id)
        }
        return nil
    }
    
    func unSelectAll(){
        for variation in variations{
            variation.isSelected = false
        }
    }
    
    func select(_ index:Int){
        unSelectAll()
        variations[index].isSelected = true
    }
}

class VariationGroupMap{
    var groupId:String = ""
    var variationId:String = ""
    
    convenience init(_ json:[AnyHashable: Any]){
        self.init()
        groupId = json["group_id"] as? String ?? ""
        variationId = json["variation_id"] as? String ?? ""
    }
    
    class func initWith(groupId:String, variationID:String) -> VariationGroupMap{
        let variationGroupMap = VariationGroupMap()
        variationGroupMap.groupId = groupId
        variationGroupMap.variationId = variationID
        return variationGroupMap
    }
}

class Exclusion{
    var variationGroups:[VariationGroupMap] = []
    
    convenience init(_ json:Any){
        self.init()
        if let variationGroupArray = json as? [[AnyHashable: Any]]{
            for variationGroup in variationGroupArray{
                variationGroups.append(VariationGroupMap(variationGroup))
            }
        }
    }
    
    func getExclusiveVariation(_ matchVariation:VariationGroupMap) -> VariationGroupMap?{
        for (index,variationGroup) in variationGroups.enumerated(){
            if variationGroup.groupId == matchVariation.groupId, variationGroup.variationId == matchVariation.variationId{
                return variationGroups[(index + 1)%2]
            }
        }
        return nil
    }
}


