//
//  InititalModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import Foundation
import PromiseKit

struct RSignUpModel {
    
    //MARK: authorization
    static func fetchLogin(login: String, password: String) -> Promise<SignUpResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "email": login,
            "password": password
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/cp/sign-in/email-password/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
}



// MARK: sign up response
struct SignUpResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: SignUpData?

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

//MARK: sign up data
struct SignUpData: Codable {
    let token: String
    let user: Profile?
}
