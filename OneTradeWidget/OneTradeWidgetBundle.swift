//
//  OneTradeWidgetBundle.swift
//  OneTradeWidget
//
//  Created by Evan Pendleton on 4/5/25.
//

import WidgetKit
import SwiftUI

@main
struct OneTradeWidgetBundle: WidgetBundle {
    var body: some Widget {
        OneTradeWidget()
        OneTradeWidgetControl()
        OneTradeWidgetLiveActivity()
    }
}
