//
//  InitialController.swift
//  Portogal
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import UIKit


extension UIViewController{
    func updateProfileData(profile: Profile){
        UserDefaults.standard.set(profile.id, forKey: "id")
        UserDefaults.standard.set(profile.login, forKey: "login")
        UserDefaults.standard.set(profile.firstName, forKey: "firstName")
        UserDefaults.standard.set(profile.lastName, forKey: "lastName")
        UserDefaults.standard.set(profile.patronymic, forKey: "patronymic")
        UserDefaults.standard.set(profile.avatar, forKey: "avatar")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile.position), forKey: "position")
        UserDefaults.standard.set(profile.userType, forKey: "userType")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile.company), forKey: "company")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile.group), forKey: "group")
    }
    
    func getProfile() -> Profile!{
        var position: Position?
        if let data = UserDefaults.standard.value(forKey:"position") as? Data {
            if data.count > 0 {
                position = try! PropertyListDecoder().decode(Position.self, from: data)
            }
        }
        
        var company: Company?
        if let data = UserDefaults.standard.value(forKey:"company") as? Data {
            if data.count > 0 {
                company = try! PropertyListDecoder().decode(Company.self, from: data)
            }
        }
        
        var group: Group?
        if let data = UserDefaults.standard.value(forKey:"group") as? Data {
            if data.count > 0 {
                group = try! PropertyListDecoder().decode(Group.self, from: data)
            }
        }
        
        return Profile(id: UserDefaults.standard.integer(forKey: "id"),
                       login: UserDefaults.standard.string(forKey: "login"),
                       firstName: UserDefaults.standard.string(forKey: "firstName"),
                       patronymic: UserDefaults.standard.string(forKey: "patronymic"),
                       lastName: UserDefaults.standard.string(forKey: "lastName"),
                       avatar: UserDefaults.standard.string(forKey: "avatar"),
                       position: position,
                       userType: UserDefaults.standard.integer(forKey: "userType"),
                       company: company,
                       group: group)
    }
}
