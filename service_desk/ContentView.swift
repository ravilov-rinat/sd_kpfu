//
//  ContentView.swift
//  service_desk
//
//  Created by MacBook on 02.01.2020.
//  Copyright © 2020 KFU. All rights reserved.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @ObservedObject var observed = Observer()
    
    var body: some View {
        NavigationView{
            List(observed.jokes){ i in
                VStack(alignment: .leading){
                    Text(i.code)
                        .font(.headline)
                    Text(i.description)
                        .lineLimit(2)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    Text(i.date)
                        .font(.subheadline)
                }
            }
            .navigationBarTitle("Текущие заявки")
        }
    }
    
    func addJoke(){
        observed.getJokes()
    }
}

struct JokesData : Identifiable{
    public var id: Int
    public var code: String
    public var description: String
    public var date: String
    //public var status: String
}

class Observer : ObservableObject{
    @Published var jokes = [JokesData]()

    init() {
        getJokes()
    }
    
    func getJokes()
    {
        AF.request("https://portal-dis.kpfu.ru/e-ksu/service_desk_mobile.get_request_list?p_user_id=230229&p2=1&p_status_id=2")
            .responseString{
                response in
                switch response.result {
                case .success(let value):
                    let stringTdata = Data(value.utf8)
                    do {
                        let json = try JSONSerialization.jsonObject(with: stringTdata, options: .mutableContainers) as! [String: AnyObject]
                        let jsonArray = json["requests"]
                                if let jsonArray = jsonArray as? Array<Dictionary<String, AnyObject?>>{
                                    for i in 0..<jsonArray.count{
                                        let json = jsonArray[i]
                                        if let id = json["id"] as? Int,
                                            let codeString = json["code"] as? String,
                                            let dateS = json["request_date"] as? String{
                                            
                                            let worksS = json["works"]
                                            if let jsArray = worksS as? Array<Dictionary<String, AnyObject?>>{
                                                for i in 0..<jsArray.count{
                                                    let js = jsArray[i]
                                                    if let desc = js["description"] as? String{
                                                        self.jokes.append(JokesData(id: id, code: codeString, description: desc, date: dateS))
                                                    }
                                                }
                                            }
                                            
                                            ///
                                            /*
                                            if let worksS = json["comments"]
                                            {if let jsArray = worksS as? Array<Dictionary<String, AnyObject?>>{
                                                for i in 0..<jsArray.count{
                                                    let js = jsArray[i]
                                                    if let desc = js["comment"] as? String{
                                                        self.jokes.append(JokesData(id: id, code: codeString, description: desc, date: dateS))
                                                    }
                                                }
                                            }}
                                            */
                                            ///
                                        }
                                        
                                    }
                                    
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
