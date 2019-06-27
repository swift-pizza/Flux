import UIKit

enum Constants {
    static let environment = Environment.local

    enum Cells {
        enum Identifiers {
            static let menu = "MenuCell"
            static let info = "InfoCell"
            static let pizza = "PizzaCell"
        }
        
        static let height = CGFloat(60.0)
    }
    
    enum ScreenTitles {
        static let project = "Flux + ViewModel"
        static let info = "Info"
    }
}
