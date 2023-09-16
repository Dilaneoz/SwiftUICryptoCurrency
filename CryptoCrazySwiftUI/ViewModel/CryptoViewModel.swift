//
//  CryptoViewModel.swift
//  CryptoViewModel
//
//  Created by Atil Samancioglu on 16.08.2021.
//

import Foundation
// mvvm çalıştığımız için kullanıcının görmeyeceği kısımları(arka planda çalışacak olan) viewmodel içinde yazarız. görüceği kısımlar view da yazılır
// burada iki tane viewmodel ımız olucak. CryptoViewModel bu modelimizi viewmodel içinde işleyebileceğimiz bi struct yapı, CryptoListViewModel bu da classımız

//Every property of this will be called on Main Thread

@MainActor // viewmodel da DispatchQueue.main.async çağırıyoruz çünkü burada cryptoList i güncellediğimizde aslında view ı güncelliyor, bunun da main thread de olması gerekiyor. ama async await ile istersek DispatchQueue.main.async i bile kullanmayabiliriz. bunun için actor u kullanmak gerek. bu şu anlama gelir, bu sınıfın içindeki property ler main threatte işlem görücek. burada cryptoList var ve main threadde işlemini yapıcak. @MainActor yazdığımız için DispatchQueue.main.async i aşağıda kullanmadan yapıyoruz. yani direkt main threadde çalışmasını istediğimiz bir sınıf varsa, @MainActor koyduğumuzda engelleyecek bi durum yoksa buu kullanabiliriz, varsa DispatchQueue.main.async ile manuel devam edebiliriz

class CryptoListViewModel : ObservableObject { // ObservableObject - öyle bi yapı kurmak istiyoruz ki cryptoList içide herhangi bi değişiklik olduğunda mainview kendi kendine yenilensin istiyoruz. swiftui da bunu @State kullanarak yapmıştık ama burda yapamayız burda apayrı bi sınıfta yapıyoruz bu işlemi. onun yerine ObservableObject kullanırız. bunun için @Published kullanırız. "@Published var" -> aynı youtube gibi düşünebiliriz burada(bi altta"@Published var cryptoList = [CryptoViewModel]()") publish ediyoruz. mainviewda da ona subscribe olucaz. yani burada (CryptoViewModel) yayın yapıcaz mainviewda da gözlemliycez o yayını. ve viewmodelda bi değişiklik olduğunda mainview kendini yeniliycek
    // birden fazla şey indireceksek hepsi için publish değişkeni oluştururuz ve view da gözlemleriz
    
    @Published var cryptoList = [CryptoViewModel]() // kripto listesini alıp kaydedeceğimiz bi yer lazım. bunu da alıp view içinde kullanıcaz o yüzden buraya bi liste oluşturuyoruz
    
    let webservice = Webservice()
    
    // 3 farklı şekilde kriptoları indirmeyi öğreniyoruz. async, continuation ve result
    
    /*
    func downloadCryptosAsync(url : URL) async {
        do {
        let cryptos = try await webservice.downloadCurrenciesAsync(url: url)
            DispatchQueue.main.async {
                self.cryptoList = cryptos.map(CryptoViewModel.init)
            }
        } catch {
            print(error)
        }
    } // buradan sonra mainview da işlem yapılacak
     */
    
    func downloadCryptosContinuation(url : URL) async {
        do {
            let cryptos = try await webservice.downloadCurrenciesContinuation(url: url) // bu bize kriptoları verir
            self.cryptoList = cryptos.map(CryptoViewModel.init) // map ile bi modeli bi modele çeviririz. CryptoViewModel.init i çeviricez. böylece indirdiğimiz kriptoları alıp CryptoViewModel e kaydedebiliriz
            /*
            DispatchQueue.main.async {
                self.cryptoList = cryptos.map(CryptoViewModel.init)
            }
             */
        } catch {
            print(error)
        }
    }
    
    /*
    func downloadCryptos(url : URL) {
        webservice.downloadCurrencies(url: url, completion: { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let cryptos):
                if let cryptos = cryptos {
                    DispatchQueue.main.async {
                        self.cryptoList = cryptos.map(CryptoViewModel.init)
                    }
                }
            }
        })
    }
     */
}

struct CryptoViewModel { // burada sadece modeli alıp işliycez
    
    let crypto : CryptoCurrency
    
    var id : UUID? {
        crypto.id // crypto.id den bunu al
    }
    
    var currency : String {
        crypto.currency
    }
    
    var price : String {
        crypto.price
    }
    
}
