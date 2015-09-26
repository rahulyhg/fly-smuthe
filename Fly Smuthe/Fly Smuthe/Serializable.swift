/*

Converts A class to a dictionary, used for serializing dictionaries to JSON

Supported objects:
- Serializable derived classes
- Arrays of Serializable
- NSData
- String, Numeric, and all other NSJSONSerialization supported objects

Credit: https://gist.github.com/turowicz/e7746a9c035356f9483d

*/


import Foundation

public class Serializable : NSObject{
    
    public func toDictionary() -> NSDictionary {
        let aClass : AnyClass? = self.dynamicType
        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(aClass, &propertiesCount)
        let propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        
        for var i = 0; i < Int(propertiesCount); i++ {
            let property = propertiesInAClass[i]
            let propName = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
            var propType = property_getAttributes(property)
            let propValue : AnyObject! = self.valueForKey(propName as String);
            
            if propValue is Serializable {
                propertiesDictionary.setValue((propValue as! Serializable).toDictionary(), forKey: propName as String)
            } else if propValue is Array<Serializable> {
                var subArray = Array<NSDictionary>()
                for item in (propValue as! Array<Serializable>) {
                    subArray.append(item.toDictionary())
                }
                propertiesDictionary.setValue(subArray, forKey: propName as String)
            } else if propValue is NSData {
                propertiesDictionary.setValue((propValue as! NSData).base64EncodedStringWithOptions([]), forKey: propName as String)
            } else if propValue is Bool {
                propertiesDictionary.setValue((propValue as! Bool).boolValue, forKey: propName as String)
            } else if(propValue is String && (propValue as! String).characters.count > 0){
                propertiesDictionary.setValue(propValue, forKey: propName as String)
            } /* else {
            propertiesDictionary.setValue(propValue, forKey: propName)
            } */
        }
        
        // class_copyPropertyList retaints all the
        propertiesInAClass.dealloc(Int(propertiesCount))
        
        return propertiesDictionary
    }
    
    public func toJson() -> NSData! {
        var dictionary = self.toDictionary()
        //println(dictionary)
        var err: NSError?
        do {
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options:NSJSONWritingOptions(rawValue: 0))
        } catch _ {
            return nil
        }
    }
    
    public func toJsonString() -> NSString! {
        return NSString(data: self.toJson(), encoding: NSUTF8StringEncoding)
    }
    
}