//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import PhotosUI

struct listTest {
    var text: String
    var clicked: Bool
}

struct TestView: View {
    @State var searchText:String = ""
    @State var array: [listTest] = []
    
    var body: some View {
        VStack{
            TextField("hello", text: $searchText).onSubmit {
                if !searchText.isEmpty{
                    array.append(listTest(text: searchText, clicked: false))
                }
            }
            
            ForEach(array.indices, id:\.self) { index in
                Button{
                    array[index].clicked.toggle()
                } label:{
                    HStack{
                        if array[index].clicked {
                            Image(systemName: "checkmark")
                        }
                        Text(array[index].text)
                    }
                }
            }
        }
    }
}



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


