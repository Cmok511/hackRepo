//
//  InitialController.swift
//  Portogal
//
//  Created by Сергей Майбродский on 20.01.2023.
//


import Foundation
import KeychainAccess

struct Constants {
    static let baseURL: URL = URL(string: "http://87.249.49.97:99")!
    static let urlString: String = "http://87.249.49.97:99"
    static let keychain = Keychain(service: "ru.axas.Portugal")
    static let gender = ["Мужской", "Женский"]
    
    
    static let complaints: [Int: String] = [0 :"Спам",
                                            1 :"Изображения обнаженного тела или действий сексуального характера",
                                            2 :"Враждебные высказывания или символы Враждебные высказывания или символы",
                                            3 :"Насилие или опасные организации",
                                            4 :"Травля или преследования",
                                            5 :"Продажа незаконных товаров или товаров, подлежащих правовому регулированию",
                                            6 :"Нарушение прав на интеллектуальную собственность",
                                            7 :"Самоубийство или нанесение себе увечий",
                                            8 :"Расстройство пищевого поведения",
                                            9 :"Мошенничество или обман",
                                            10:"Ложная информация"]
}


//MARK: ORDER STATUS
//created = 0 # Заказ создан. Выбираем отклики
//selected = 1 # Выбрали отклик-победитель
//finished = 2 # Работа с откликом завершена. Ожидаем подтверждения
//confirmed = 3 # Работа с откликом подтверждена
//rejected = 4 # Заказ отклонён
