//
//  Webservice.swift
//  Webservice
//
//  Created by Atil Samancioglu on 16.08.2021.
//

import Foundation

// bu uygulamayı mvvm e uygun yazıcaz
// webserviste daha önce öğrendiğimiz urlsession ı kullanıcaz. mvvm e uygun yazıcaz

// async bi işlemin asenkron olarak yapılacağını söyler. aynı zamanda bu taskları paralel programlamayla/tradingle yapmaya çalışıyor sistem
// fonksiyonda tanımlarken parametrelerden sonra ve bi şeyi döndürmeden önce async olduğunu yazarız. hata döndürecekse yanına throws yazarız
// await ise işlem oluncaya kadar bekle demek. arka planda birçok şey dönüyor. ios işletim sisteminin kendisi isterse bu fonksiyonu duraklatıp devam ettirebiliyor ve bunu yapıp yapmıycağına sistem karar veriyor. bu kararlar milisaniyelerde olur. yoğunluğa göre önceliklendirilir. sonucunda çıkan şey beklenir ve direkt sonucu alabiliyoruz
// async ve await i escaping yerine kullanabiliyoruz(bu classta bunu yapıcaz). bu bazı avantajlar sağlar

class Webservice {
    
    /*
    func downloadCurrenciesAsync(url: URL) async throws -> [CryptoCurrency] { // async kullandığımız için ne döndürceğini direkt yazabiliyoruz. escapingte result ı kullanmak gerekiyordu
        // response u kullanmıycaksak (data, _) böyle de yazabiliriz
        let (data, response) = try await URLSession.shared.data(from: url) // data async olarak çalışan bi fonksiyon. datatask yerine bunu kullanırız. burada bize ben bunu CryptoCurrency e çeviremiyorum nası çeviricem diyo. burda da aynı datatask gibi bize data ve response verir. hatayı vermiyo çünkü hata zaten throwing. do try catch e almak istemiyosak yukarıda async throws yazarız ve hataları burada ele almayacağımızı söyleriz. bu fonksiyonu nerede kullanırsak orada do try catch i yapmak isteyebiliriz, örneğin viewmodel ın içinde. buradan sonra viewmodel da işleme devam edicez. bi şey async ise await i kullanmak zorundayız
        
        let currencies = try? JSONDecoder().decode([CryptoCurrency].self, from: data)
        
        return currencies ?? [] // boşsa boş bi dizi yolla
    }
     */
    
    func downloadCurrenciesContinuation(url : URL) async throws -> [CryptoCurrency] { // Continuation devamlılık.
        //this will allow to resume from the suspended state
        try await withCheckedThrowingContinuation { continuation in // withCheckedThrowingContinuation bunun yaptığı güncel task ı duraklatmak. burada herhangi bi fonksiyonu async olmasa da async hale getirip istediğimiz zaman duraklatıp devam ettirebiliyoruz. manuel olarak devam ettiriceğimiz yeri biz seçicez. bu fonksiyon bize kontrol edilmiş continuation verir
            downloadCurrencies(url: url) { result in // downloadCurrencies bu async olmayan bi fonksiyon bunu async hale getirmeye çalışıyoruz. bi alttaki downloadCurrencies fonksiyonunu continuation ı kullanarak async hale getirdik ve duraklatma yeteneğini buna kazandırmış olduk
                switch result {
                case .success(let cryptos):
                    continuation.resume(returning: cryptos ?? []) // resume diyerek devam et diyoruz sonra kriptoları döndür ya da olmazsa boş bi dizi döndür diyoruz
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func downloadCurrencies(url: URL, completion: @escaping (Result<[CryptoCurrency]?,DownloaderError>) -> Void) { // @escaping iş tamamlanınca bana şunu ver anlamına gelir. daha önce gördük
        
        URLSession.shared.dataTask(with: url) { data, response, error in // URLSession.shared.dataTask bu kısım arka planda yapılıyor. URLSession da aslında asenkron çalışır ama async ve await i kullanmak gerekiyorsa üstteki fonksiyonda yaptığımız gibi bi fonksiyonu async ve await in task ine çevirebiliriz
            
        if let error = error {
            print(error.localizedDescription)
            completion(.failure(.badUrl)) // completion.failure bu kısım Result sayesinde gelir. completion la bunu döndürüyoruz
        }
            
        guard let data = data, error == nil else { // guard let "data = data, error == nil" bu kısmı doğru kabul eder
            return completion(.failure(.noData)) // guard let kullanıyosak return kullanmak gerekir
        }
            
        guard let currencies = try? JSONDecoder().decode([CryptoCurrency].self, from: data) else { // do try catch yapmamak için try? optional yazdık
            return completion(.failure(.dataParseError))
        }
            completion(.success(currencies))
        }.resume() // URLSession resume etmemizi ister
    }
}


enum DownloaderError: Error { // aslında yukarıda klasik bi hata verdirebilirdik ama profesyonel hayatta bu enum içerisinde yapılır. farklı farklı hatalar için farklı case ler yazıyoruz. bu debug ederken çok işimize yarıyor
    case badUrl // bunları biz yazdık hazır değil. urlyi yanlış vermişizdir ya da internet yoktur
    case noData // data gelmedi
    case dataParseError // veri geldi ama parse edemedik. modeli yanlış yazdık vs
}
