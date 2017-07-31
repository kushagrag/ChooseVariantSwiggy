//
//  ViewController.swift
//  SwiggyTest
//
//  Created by Kushagra Gupta on 29/07/17.
//  Copyright © 2017 Kushagra Gupta. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController ,
    UITableViewDelegate,
    UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    var variantGroups:[VariantGroup] = []
    var exclusions:[Exclusion] = []
    var selectedVariants:[VariationGroupMap] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        fetchData()
        setUpSubmitButton()
        title = "Variants"
    }
    
    //MARK: Setup Views
    func setUpSubmitButton(){
        submitButton.isEnabled = false
    }
    
    func setUpTableView(){
        tableView.register(UINib.init(nibName: "VariationTableViewCell", bundle: nil), forCellReuseIdentifier: "VariationTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
    }
    
    //MARK: Fetch Data
    func fetchData(){
        startActivityIndicator()
        _ = Alamofire.request("https://api.myjson.com/bins/3b0u2")
        .validate()
        .responseJSON(completionHandler: { response in
            self.stopActivityIndicator()
            switch response.result{
            case .success(let responseObject):
                self.parseSuccessfulResponse(responseObject)
            case .failure:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.fetchData()
                })
                self.showAlert(title: "Error", messgae: "Something Went Wrong", action:retryAction)
            }
        })
    }
    
    func parseSuccessfulResponse(_ response:Any){
        if let responseJSON = response as? [AnyHashable: Any], let variantsJSON = responseJSON["variants"] as? [AnyHashable: Any]{
            variantGroups.removeAll()
            exclusions.removeAll()
            selectedVariants.removeAll()
            if let variantGroupsJSON = variantsJSON["variant_groups"] as? [[AnyHashable: Any]]{
                for variantGroupJSON in variantGroupsJSON{
                    let variantGroup = VariantGroup(variantGroupJSON)
                    variantGroups.append(variantGroup)
                    if let defaultVariation = variantGroup.getDefaultVariation(){
                        selectedVariants.append(defaultVariation)
                    }
                }
            }
            if let excludesJSON = variantsJSON["exclude_list"] as? [Any]{
                for excludeJSON in excludesJSON{
                    exclusions.append(Exclusion(excludeJSON))
                }
            }
        }
        tableView.reloadData()
        submitButton.isEnabled = true
    }
    
    //MARK: Utilities
    func canSelectVariation(_ variantGroupMap:VariationGroupMap) -> Bool{
        //var exclusiveVariants:[VariationGroupMap] = []
        for exclusion in exclusions{
            if let exclusiveVariant = exclusion.getExclusiveVariation(variantGroupMap){
                if findSelectedVariantGroup(variantGroupMap: exclusiveVariant) != nil{
                    return false
                }
            }
        }
        return true
    }
    
    func findSelectedVariantGroup(variantGroupMap:VariationGroupMap) -> VariationGroupMap?{
        return selectedVariants.filter({ $0.groupId == variantGroupMap.groupId && $0.variationId == variantGroupMap.variationId }).first
    }
    
    func findVariantGroup(groupId:String) -> VariantGroup?{
        return variantGroups.filter({ $0.groupId == groupId }).first
    }
    
    func findVariation(variantGroup:VariantGroup, id:String) -> Variation?{
        return variantGroup.variations.filter({ $0.id == id }).first
    }
    
    func showAlert(title:String, messgae:String, action:UIAlertAction?){
        let alertController = UIAlertController(title: title, message: messgae, preferredStyle: .alert)
        
        if action != nil{
            alertController.addAction(action!)
        }else{
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func startActivityIndicator(){
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    //MARK: TableView dataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return variantGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variantGroups[section].variations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VariationTableViewCell", for: indexPath) as! VariationTableViewCell
        cell.setUpCell(variantGroups[indexPath.section].variations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return variantGroups[section].name
    }
    
    //MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let variationGroup = variantGroups[indexPath.section]
        let variation = variationGroup.variations[indexPath.row]
        let variationGroupMap = VariationGroupMap.initWith(groupId: variationGroup.groupId, variationID: variation.id)
        
        if !variation.inStock{
            showAlert(title: "Not in Stock", messgae: "This variaton is not currently available", action: nil)
            return 
        }
        
        if canSelectVariation(variationGroupMap){
            if let index = selectedVariants.index(where: { $0.groupId == variationGroupMap.groupId }){
                selectedVariants.remove(at: index)
            }
            selectedVariants.append(variationGroupMap)
            variationGroup.select(indexPath.row)
            tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .none)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
            showAlert(title: "Not Valid", messgae: "This combination of variations is not allowed", action: nil)
        }
    }
    
    //MARK: IBActions
    @IBAction func submit(_ sender: Any) {
        var message = "You Selected\n"
        for selectedVariant in selectedVariants{
            if let variantGroup = findVariantGroup(groupId: selectedVariant.groupId),let variation = findVariation(variantGroup: variantGroup, id: selectedVariant.variationId){
                message += "\(variation.name) \(variantGroup.name)\n"
            }
        }
        message.remove(at: message.index(before: message.endIndex))
        showAlert(title: "Got your choice", messgae: message, action: nil)
    }
}

