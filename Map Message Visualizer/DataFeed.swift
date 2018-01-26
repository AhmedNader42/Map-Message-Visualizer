//
//  DataFeed.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/6/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import Foundation

class DataFeed {
    
    
    func getData(URLString urlString : String) {
        let url = URL(string: urlString)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {
            data,respnse,error in
            
            if error != nil {
                print("Error : \(error?.localizedDescription)")
            } else {
                
                do{
                    let d = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    //print("Data[feed] : \(d["feed"])")
                    let e = d["feed"] as! [String:Any]
                    //print("Data[entry] : \(e["entry"]) ")
                    
                    let every = e["entry"] as! [[String:Any]]
                    
                    for each in every {
                        //print("Each : \(each["content"]!) ")
                        let m = each["content"] as! [String:String]
                        
                        
                        print("Message : \(m["$t"]!)")
                        let sep = m["$t"]
                        
                        
                        let components = sep?.components(separatedBy: ",")
                        
                        if components != nil{
                            DispatchQueue.main.async {
                                self.displayDataOnMap(forComponents: components!)
                            }
                        } else {
                            print("Error")
                        }
                    }
                    
                } catch let err as NSError {
                    print("JSON Error : \(err.localizedDescription)")
                }
            }
            
        }
        dataTask.resume()

    }
}
