//
//  ContentView.swift
//  Recordium_Swift
//
//  Created by 龙龙 on 2025/2/23.
//

import SwiftUI
import SwiftData

/// 主内容视图 - 应用的主入口视图
/// 目前用于测试数据模型关联关系
struct ContentView: View {
    // MARK: - 环境属性
    
    /// SwiftData模型上下文
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - 状态属性
    
    /// 当前选中的标签页
    @State private var selectedTab: Tab = .home
    
    // MARK: - 视图主体
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页标签页 - 用于测试数据模型关系
            ModelTestView()
                .tabItem {
                    Label("模型测试", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            // 个人资料标签页 - 暂未实现
            Text("个人资料页面 - 待实现")
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
    }
}

/// 标签页枚举
enum Tab {
    case home
    case profile
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: User.self, Space.self, RecordBox.self, Album.self, UserSettings.self,
        configurations: config
    )
    
    return ContentView()
        .modelContainer(container)
}
