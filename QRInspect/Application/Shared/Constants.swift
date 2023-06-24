//
//  InitialController.swift
//
//  Created by Сергей Майбродский on 20.01.2023.
//


import Foundation
import KeychainAccess

struct Constants {
    static let baseURL: URL = URL(string: "http://87.249.49.97:90")!
    static let urlString: String = "http://87.249.49.97:90"
    static let keychain = Keychain(service: "ru.axas.QRInspect")
    static let gender = ["Мужской", "Женский"]
    
    
    static let taskStatus: [Int: String] = [  0: "Создано",
                                              1: "Отклонёно",
                                              2: "Выполняется специалистом",
                                              3: "Выполнено",
                                              4: "Переназначено"]
}


//MARK: ORDER STATUS
//created = 0 # Заказ создан. Выбираем отклики
//selected = 1 # Выбрали отклик-победитель
//finished = 2 # Работа с откликом завершена. Ожидаем подтверждения
//confirmed = 3 # Работа с откликом подтверждена
//rejected = 4 # Заказ отклонён

enum Stage: String, CaseIterable {
    case budburst = "Распускание почек"
    case flower_cluster_initiation = "Начало цветения"
    case flowering = "Цветение"
    case fruit_set = "Завязывание плодов"
    case berry_development = "Ягодное развитие"
    case harvest = "Период покоя"
    case dormancy = "Урожая"
}
