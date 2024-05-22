/*
 Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */


import Foundation
import AWSCore


@objcMembers
public class APIGetUserInfoSchema : AWSModel {
    
    enum GenderEnum: String { 
        case MALE = "MALE"
        case FEMALE = "FEMALE"
    }
    
    var lastName: String!
    var verifiedPhone: NSNumber!
    var occupation: String!
    var gender: String!
    var subToEmail: NSNumber!
    var birthDate: String!
    var createdAt: String!
    var firstName: String!
    var phoneNumber: String!
    var profilePhotos: [String]!
    var location: APIGetUserInfoSchema_location!
    var id: String!
    var visibleGender: NSNumber!
    var interests: [APIGetUserInfoSchema_interests_item]!
    var email: String!
    var verifiedEmail: NSNumber!
    
   	public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]!{
		var params:[AnyHashable : Any] = [:]
		params["lastName"] = "lastName"
		params["verifiedPhone"] = "verifiedPhone"
		params["occupation"] = "occupation"
		params["gender"] = "gender"
		params["subToEmail"] = "subToEmail"
		params["birthDate"] = "birthDate"
		params["createdAt"] = "createdAt"
		params["firstName"] = "firstName"
		params["phoneNumber"] = "phoneNumber"
		params["profilePhotos"] = "profilePhotos"
		params["location"] = "location"
		params["id"] = "id"
		params["visibleGender"] = "visibleGender"
		params["interests"] = "interests"
		params["email"] = "email"
		params["verifiedEmail"] = "verifiedEmail"
		
        return params
	}
	class func locationJSONTransformer() -> ValueTransformer{
	    return ValueTransformer.awsmtl_JSONDictionaryTransformer(withModelClass: APIGetUserInfoSchema_location.self);
	}
	class func interestsJSONTransformer() -> ValueTransformer{
		return  ValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: APIGetUserInfoSchema_interests_item.self);
	}
}
