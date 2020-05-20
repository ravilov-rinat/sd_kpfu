//
//  MainView.swift
//  service_desk
//
//  Created by MacBook on 04.01.2020.
//  Copyright © 2020 KFU. All rights reserved.
//

import SwiftUI
import Alamofire

struct MainView: View {
    @ObservedObject var observed = Observer()
    
    var body: some View {
            List(observed.jokes){ i in
                HStack{
                    Text(i.joke)}
                
                }
            .navigationBarTitle("Текущие заявки")
    }
    func addJoke(){
        observed.getJokes()
    }
}

struct JokesData : Identifiable{
    public var id: Int
    public var joke: String
}

class Observer : ObservableObject{
    @Published var jokes = [JokesData]()

    init() {
        getJokes()
    }
    
    func getJokes()
    {
        AF.request("https://portal-dis.kpfu.ru/e-ksu/service_desk_mobile.get_user_request_list?p_user_id=230229&p2=1&p_status_id=3&p_page_size=1&p_page=1")
            .responseString{
                response in
                switch response.result {
                case .success(let value):
                    var cup: Int
                    let data = Data(value.utf8)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                            if let names = json["pagination"] {
                                cup = names["current_page"] as! Int
                                print(cup)
                            }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
