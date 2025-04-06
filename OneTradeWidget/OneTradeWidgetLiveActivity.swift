//
//  OneTradeWidgetLiveActivity.swift
//  OneTradeWidget
//
//  Created by Evan Pendleton on 4/5/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct OneTradeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct OneTradeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OneTradeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension OneTradeWidgetAttributes {
    fileprivate static var preview: OneTradeWidgetAttributes {
        OneTradeWidgetAttributes(name: "World")
    }
}

extension OneTradeWidgetAttributes.ContentState {
    fileprivate static var smiley: OneTradeWidgetAttributes.ContentState {
        OneTradeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: OneTradeWidgetAttributes.ContentState {
         OneTradeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: OneTradeWidgetAttributes.preview) {
   OneTradeWidgetLiveActivity()
} contentStates: {
    OneTradeWidgetAttributes.ContentState.smiley
    OneTradeWidgetAttributes.ContentState.starEyes
}
