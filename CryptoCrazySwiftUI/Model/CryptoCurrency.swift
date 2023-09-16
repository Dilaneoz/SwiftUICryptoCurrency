//
//  CryptoCurrency.swift
//  CryptoCurrency
//
//  Created by Atil Samancioglu on 16.08.2021.
//

import Foundation
// modelimiz
struct CryptoCurrency: Hashable, Decodable, Identifiable { // swiftui de Identifiable ı da ekleriz çünkü listeye verince bunları bi id gerekecek. Hashable, CodingKey kullanırken kullanılması tavsiye ediliyo
    let id = UUID()
    let currency: String
    let price: String
    
    private enum CodingKeys: String, CodingKey { // CodingKey protocol bi arayüz. case lerle enumlarla hangi değişken için hangi şekilde hangi isimde geliceğini belirtebildiğimiz bir yapı
        // bu kısmı yapma sebebi yukarıdaki structta modeli yazarken id de kullandık, web servisten gelen datada id olmayacak o yüzden sistem karışabilir. burada enum oluşturarak sadece gelecek dataları verdik
        case currency = "currency"
        case price = "price"
    }
}
