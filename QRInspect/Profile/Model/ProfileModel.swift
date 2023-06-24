//
//  ProfileModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import Foundation
import PromiseKit

struct ProfileModel {
    
    //MARK:  edit profile
    static func editProfile(firstName: String, lastName: String, patronymic: String, email: String?,tg: String?, isServicer: Bool, gender: Int, birthtime: Int, location: String, serviceCategory: Int?, showTel: Bool, isBusiness: Bool) -> Promise<ProfileResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var param: [String: Encodable] = [
            "first_name": firstName,
            "patronymic": patronymic,
            "last_name": lastName,
            "email": email,
            "tg": tg,
            "is_servicer": isServicer,
            "birthtime": birthtime,
            "gender": gender,
            "location": location,
            "show_tel": showTel,
            "is_business": isBusiness]
        
        if serviceCategory != nil {
            param["category_id"] = serviceCategory
        }
        
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .PUT(url: url, body: data!))
    }
    
    
    
    //MARK:  get profile
    static func fetchProfile() -> Promise<ProfileResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK:  add photo
    static func changeAvatar(image: Data) -> Promise<ProfileResponse>{
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/v1/users/me/avatars/")
        let media = NetCoreMedia(with: image, forKey: "new_avatar", mediaType: .image)
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
    
    
    //MARK: fetch user info
    static func fetchUser(userId: Int) -> Promise<UserResponse> {
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    
    //MARK: complaint user
    static func complaintUser(userId: Int, complaint: Int, comment: String) -> Promise<StatusResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "reason": complaint,
            "additional_text": comment
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/reports/")
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }
    
    //MARK: block user
    static func blockUser(userId: Int, isBlock: Bool) -> Promise<StatusResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "block": isBlock
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/block/")
        return CoreNetwork.request(method: .PUT(url: url, body: data))
    }
    
    
    
    //MARK: delete profile
    static func deleteProfile() -> Promise<StatusResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .DELETE(url: url))
    }
    
    
    //MARK: get notification
    static func fetchNotification() -> Promise<NotificationListResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/notifications/")
        return CoreNetwork.request(method: .GET(url: url))
    }
}



// MARK: PROFILE
struct ProfileResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: Profile?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}


struct Profile: Codable {
    let id: Int?
    let login, firstName, patronymic, lastName: String?
    let avatar: String?
    let position: Position?
    let userType: Int?
    let company: Company?
    let group: Group?
}

// MARK: - Company
struct Company: Codable {
    let name: String
    let id: Int
    let addresses: [Address]?
}

// MARK: - Group
struct Group: Codable {
    let name: String
    let id: Int
}
// MARK: - Position
struct Position: Codable {
    let name: String?
    let id: Int?
}


// MARK: USER
struct UserResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: User?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}



struct User: Codable {
    let id: Int?
    let login, firstName, patronymic, lastName: String?
    let avatar: String?
    let position: Position?
    let userType: Int?
    let company: Company?
    let group: Group?
}

//MARK: NOTIFICATION
struct NotificationListResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: [NotificationInfo?]
}

struct NotificationInfo: Codable {
    let id: Int?
    let title, body, icon: String?
    let created, orderID, offerID, stage: Int?
    let isRead: Bool?
}


