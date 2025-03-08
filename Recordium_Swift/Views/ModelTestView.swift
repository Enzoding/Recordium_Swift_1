//
//  ModelTestView.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import SwiftUI
import SwiftData

/// 模型测试视图
/// 用于验证User和Space之间的关联关系
struct ModelTestView: View {
    // MARK: - 环境属性
    
    /// SwiftData模型上下文
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - 查询属性
    
    /// 查询所有用户
    @Query private var users: [User]
    
    // MARK: - 状态属性
    
    /// 新用户名称
    @State private var newUserName = ""
    
    /// 新用户Apple ID
    @State private var newUserAppleId = ""
    
    /// 选中的用户
    @State private var selectedUser: User?
    
    /// 新空间名称
    @State private var newSpaceName = ""
    
    /// 显示详情的空间
    @State private var selectedSpace: Space?
    
    /// 是否显示空间详情
    @State private var showingSpaceDetail = false
    
    /// 新唱片盒名称
    @State private var newRecordBoxName = ""
    
    /// 选中的唱片盒
    @State private var selectedRecordBox: RecordBox?
    
    /// 是否显示唱片盒详情
    @State private var showingRecordBoxDetail = false
    
    // MARK: - 视图主体
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 创建用户表单
                createUserForm
                
                // 用户列表
                usersList
            }
            .padding()
            .navigationTitle("模型关系测试")
            .sheet(isPresented: $showingSpaceDetail) {
                if let space = selectedSpace {
                    spaceDetailView(space: space)
                }
            }
        }
    }
    
    // MARK: - 创建用户表单
    
    private var createUserForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("创建新用户")
                .font(.headline)
            
            TextField("用户名", text: $newUserName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Apple ID", text: $newUserAppleId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: createUser) {
                Text("添加用户")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(newUserName.isEmpty || newUserAppleId.isEmpty)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 用户列表
    
    private var usersList: some View {
        List {
            ForEach(users) { user in
                userSection(user: user)
            }
            .onDelete(perform: deleteUsers)
        }
    }
    
    // MARK: - 用户部分
    
    private func userSection(user: User) -> some View {
        Section {
            // 用户信息
            VStack(alignment: .leading, spacing: 8) {
                Text(user.name)
                    .font(.headline)
                
                Text("Apple ID: \(user.appleId)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("创建时间: \(user.createdAt.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("空间数量: \(user.spaces.count)")
                    .font(.subheadline)
                    .padding(.top, 4)
            }
            .padding(.vertical, 8)
            .onTapGesture {
                selectedUser = (selectedUser?.id == user.id) ? nil : user
            }
            
            // 如果用户被选中，显示空间列表和添加空间表单
            if selectedUser?.id == user.id {
                // 空间列表
                ForEach(user.spaces) { space in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(space.name)
                                .font(.headline)
                            
                            Text("创建时间: \(space.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedSpace = space
                            showingSpaceDetail = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 16)
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteSpace(space, from: user)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
                
                // 添加空间表单
                HStack {
                    TextField("新空间名称", text: $newSpaceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        addSpace(to: user)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newSpaceName.isEmpty)
                }
                .padding(.vertical, 8)
                .padding(.leading, 16)
            }
        }
    }
    
    // MARK: - 空间详情视图
    
    private func spaceDetailView(space: Space) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 空间基本信息
                Group {
                    Text("空间名称: \(space.name)")
                        .font(.headline)
                    
                    Text("ID: \(space.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("创建时间: \(space.createdAt.formatted())")
                    
                    Text("更新时间: \(space.updatedAt.formatted())")
                    
                    Text("所属用户: \(space.user?.name ?? "无")")
                    
                    Text("唱片盒数量: \(space.recordBoxes.count)")
                }
                .padding(.horizontal)
                
                Divider()
                
                // 验证与用户的双向关系
                if let user = space.user {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("验证与用户的关系:")
                            .font(.headline)
                        
                        Text("1. 该空间属于用户: \(user.name)")
                        
                        Text("2. 用户的空间列表中是否包含该空间: \(user.spaces.contains(where: { $0.id == space.id }) ? "是" : "否")")
                        
                        if user.spaces.contains(where: { $0.id == space.id }) {
                            Text("3. 关系验证: 成功 ✓")
                                .foregroundColor(.green)
                        } else {
                            Text("3. 关系验证: 失败 ✗")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                } else {
                    Text("该空间没有关联用户")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Divider()
                
                // 唱片盒管理部分
                VStack(alignment: .leading, spacing: 12) {
                    Text("唱片盒管理")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // 添加唱片盒表单
                    HStack {
                        TextField("新唱片盒名称", text: $newRecordBoxName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            addRecordBox(to: space)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .disabled(newRecordBoxName.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // 唱片盒列表
                    List {
                        ForEach(space.recordBoxes) { recordBox in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(recordBox.name)
                                        .font(.headline)
                                    
                                    Text("ID: \(recordBox.id)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 验证唱片盒与空间的双向关系
                                if recordBox.space?.id == space.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteRecordBox(recordBox, from: space)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("空间详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") {
                        showingSpaceDetail = false
                    }
                }
            }
        }
    }
    
    // MARK: - 操作方法
    
    /// 创建新用户
    private func createUser() {
        let user = User(appleId: newUserAppleId, name: newUserName)
        modelContext.insert(user)
        
        // 清空表单
        newUserName = ""
        newUserAppleId = ""
    }
    
    /// 添加空间到用户
    private func addSpace(to user: User) {
        let space = Space(name: newSpaceName)
        user.spaces.append(space)
        
        // 清空表单
        newSpaceName = ""
    }
    
    /// 删除空间
    private func deleteSpace(_ space: Space, from user: User) {
        if let index = user.spaces.firstIndex(where: { $0.id == space.id }) {
            user.spaces.remove(at: index)
            modelContext.delete(space)
        }
    }
    
    /// 删除用户
    private func deleteUsers(at offsets: IndexSet) {
        for index in offsets {
            let user = users[index]
            modelContext.delete(user)
            
            if selectedUser?.id == user.id {
                selectedUser = nil
            }
        }
    }
    
    // MARK: - RecordBox操作方法
    
    /// 添加唱片盒到空间
    private func addRecordBox(to space: Space) {
        let recordBox = RecordBox(name: newRecordBoxName)
        space.recordBoxes.append(recordBox)
        
        // 清空表单
        newRecordBoxName = ""
    }
    
    /// 删除唱片盒
    private func deleteRecordBox(_ recordBox: RecordBox, from space: Space) {
        if let index = space.recordBoxes.firstIndex(where: { $0.id == recordBox.id }) {
            space.recordBoxes.remove(at: index)
            modelContext.delete(recordBox)
        }
    }
}

// MARK: - 预览

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Space.self, RecordBox.self, Album.self, UserSettings.self, configurations: config)
    
    // 创建预览数据
    let user = User(appleId: "preview_user", name: "预览用户")
    let space = Space(name: "预览空间")
    user.spaces.append(space)
    
    container.mainContext.insert(user)
    
    return ModelTestView()
        .modelContainer(container)
}
