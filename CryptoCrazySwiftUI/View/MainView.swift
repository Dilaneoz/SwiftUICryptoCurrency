//
//  MainView.swift
//  CryptoCrazySwiftUI
//
//  Created by Atil Samancioglu on 16.08.2021.
//

import SwiftUI


struct MainView: View {
    
    @ObservedObject var cryptoListViewModel : CryptoListViewModel

    init() { // init görünüm oluşturulduğunda ilk çağırılacak şeylerden biri
          self.cryptoListViewModel = CryptoListViewModel()
    }
    
    
    var body: some View { // verileri çekicez
        NavigationView{
        
            
            List(cryptoListViewModel.cryptoList,id:\.id) { crypto in
          
                VStack{
    
                Text(crypto.currency)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)

                Text(crypto.price)
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity, alignment: .leading) // infinity deyince cell i uzatabildiği kadar uzatır

                }
            
            }.toolbar(content: { // refresh e basıldığında kriptolar güncellenecek
                Button {
                    // butona tıklanınca ne olucağını yazıcaz buraya
                    Task.init { // buton async olmadığı için await içinde çalıştırılmıyor. Task.init kullanarak async bi kod bloğu açıyoruz
                        //cryptoListViewModel.cryptoList = [] // bunu refresh e bastığımızda başta çok kısa süreliğine boş bi görüntü gelmesi sonra ekranın yanilenmesi için yapabiliriz
                        await cryptoListViewModel.downloadCryptosContinuation(url: URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")!)
                    }
                } label: { // butonda ne yazıcağı
                    Text("Refresh")
                }

            })
            .navigationTitle(Text("Crypto Crazy"))
            
        }.task{ // burada .onAppear kullanamıyoruz çünkü .onAppear async değil. .task in kendisi asenkron o yüzden onu kullanıyoruz. bu fonksiyon da async olduğu için çalışıyor. task i kullanarak uygulama açıldığı gibi verilerin çekilip gösterilebilmesine olanak tanıdık
            /*
            await cryptoListViewModel.downloadCryptosAsync(url: URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")!)
             */
            
            await cryptoListViewModel.downloadCryptosContinuation(url: URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")!)
        }
        
        /*.onAppear { // onAppear, bizim yaşam döngüsü fonksiyonlarımızdan bu görünüm oluşturulunca ne yapılacağını sorar. downloadCryptos u çağır dedik
            cryptoListViewModel.downloadCryptos(url: URL(string:  "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")!)
        }*/
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
