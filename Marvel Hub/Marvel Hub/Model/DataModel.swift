
//
//  DataModel.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import Foundation

//MARK:-  An outermost wrapper model for a Marvel Character with the variables needed to quickly decode the response.

struct ResponseModelCharacter:Codable{
    var code:Int?
    var status:String?
    var data:DataObjCharacter?
}

//MARK:- Itermediate Character model.

struct DataObjCharacter:Codable{
    var total:Int?
    var results:[Character]?
}

//MARK:- A Marvel character model with all the character's attributes.

struct Character:Codable {
    var id:Int?
    var name:String?
    var description:String?
    var thumbnail:Image?
}

struct ResponseModelComic:Codable{
    var code:Int?
    var status:String?
    var data:DataObjComic?
}

struct DataObjComic:Codable{
    var total:Int?
    var results:[Comic]?
}

//MARK:- A Marvel comic model with all the comic's attributes.

struct Comic:Codable {
    var id:Int?
    var digitalId:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct ResponseModelEvent:Codable{
    var code:Int?
    var status:String?
    var data:DataObjComic?
}
struct DataObjEvent:Codable{
    var total:Int?
    var results:[Event]?
}

//MARK:- A Marvel event model with all the comic's attributes.

struct Event:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct ResponseModelSeries:Codable{
    var code:Int?
    var status:String?
    var data:DataObjSeries?
}
struct DataObjSeries:Codable{
    var total:Int?
    var results:[Series]?
}

//MARK:- A Marvel series model with all the comic's attributes.

struct Series:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct ResponseModelStories:Codable{
    var code:Int?
    var status:String?
    var data:DataObjStories?
}
struct DataObjStories:Codable{
    var total:Int?
    var results:[Story]?
}

//MARK:- A Marvel story model with all the comic's attributes.

struct Story:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}

//MARK:- An image thumbnail model that is shared among all models with the image extension attribute renamed to "imageExtension" so as not to clash with Swift's "extension" keyword
struct Image:Codable {
    var path:String?
    var imageExtension:String?
    
    private enum CodingKeys : String, CodingKey {
        case path = "path"
        case imageExtension = "extension"
    }
}
