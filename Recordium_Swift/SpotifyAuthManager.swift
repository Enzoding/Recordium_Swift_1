import Foundation
import SpotifyWebAPI
import Combine
import SwiftUI
import KeychainAccess

class SpotifyAuthManager: ObservableObject {
    // MARK: - Properties
    static let shared = SpotifyAuthManager()
    
    @Published var isAuthorized = false
    @Published var authError: String?
    @Published var currentUser: SpotifyUser?
    @Published var isRetrievingTokens = false
    
    private let clientId = "b407cd6391424acd9d059f234bbdc126"
    private let clientSecret = "9d7c0f8507b84c008c8976f6eb4c5919"
    private let authorizationManagerKey = "spotifyAuthorizationManager"
    private let loginCallbackURL = URL(string: "recordium://spotify-callback")!
    
    private var authorizationState = String.randomURLSafe(length: 128)
    private var cancellables: Set<AnyCancellable> = []
    private let keychain = Keychain(service: "top.peaceding.Recordium")
    
    let api: SpotifyAPI<AuthorizationCodeFlowManager>
    
    // MARK: - Initialization
    private init() {
        // 初始化 SpotifyAPI 实例
        api = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: clientId,
                clientSecret: clientSecret
            )
        )
        
        print("SpotifyAuthManager: 初始化完成")
        
        setupSubscriptions()
        restoreFromKeychain()
    }
    
    // MARK: - Setup
    private func setupSubscriptions() {
        // 订阅授权状态变化
        api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
            
        print("SpotifyAuthManager: 订阅设置完成")
    }
    
    private func restoreFromKeychain() {
        if let authManagerData = keychain[data: authorizationManagerKey] {
            do {
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                print("SpotifyAuthManager: 从 keychain 恢复授权信息成功")
                api.authorizationManager = authorizationManager
            } catch {
                print("SpotifyAuthManager: 从 keychain 恢复授权信息失败: \(error)")
            }
        } else {
            print("SpotifyAuthManager: keychain 中未找到授权信息")
        }
    }
    
    // MARK: - Authorization
    func authorize() {
        guard let authURL = api.authorizationManager.makeAuthorizationURL(
            redirectURI: loginCallbackURL,
            showDialog: true,
            state: authorizationState,
            scopes: [
                .userReadPlaybackState,
                .userModifyPlaybackState,
                .userReadCurrentlyPlaying,
                .playlistModifyPublic,
                .playlistModifyPrivate,
                .userLibraryRead,
                .userLibraryModify
            ]
        ) else {
            print("SpotifyAuthManager: 无法生成授权 URL")
            self.authError = "无法生成授权 URL"
            return
        }
        
        print("SpotifyAuthManager: 开始授权")
        print("SpotifyAuthManager: 回调 URL - \(loginCallbackURL)")
        print("SpotifyAuthManager: 授权 URL - \(authURL)")
        print("SpotifyAuthManager: State - \(authorizationState)")
        
        UIApplication.shared.open(authURL)
    }
    
    func handleCallback(_ url: URL) {
        print("SpotifyAuthManager: 收到回调 URL - \(url)")
        
        isRetrievingTokens = true
        
        api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: authorizationState
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isRetrievingTokens = false
                
                switch completion {
                case .finished:
                    print("SpotifyAuthManager: 授权流程完成")
                    self.authError = nil
                case .failure(let error):
                    print("SpotifyAuthManager: 授权错误 - \(error)")
                    if let authError = error as? SpotifyAuthorizationError {
                        if authError.accessWasDenied {
                            self.authError = "用户拒绝了授权请求"
                        } else {
                            self.authError = "授权失败：\(authError.localizedDescription)"
                        }
                    } else {
                        self.authError = "授权失败：\(error.localizedDescription)"
                    }
                }
            },
            receiveValue: { [weak self] tokenData in
                print("SpotifyAuthManager: 成功获取令牌 - \(tokenData)")
                self?.authError = nil
            }
        )
        .store(in: &cancellables)
        
        // 生成新的 state 参数
        self.authorizationState = String.randomURLSafe(length: 128)
    }
    
    // MARK: - Authorization State Changes
    private func authorizationManagerDidChange() {
        withAnimation {
            isAuthorized = api.authorizationManager.isAuthorized()
        }
        
        print("SpotifyAuthManager: 授权状态改变 - isAuthorized: \(isAuthorized)")
        
        if isAuthorized {
            retrieveCurrentUser()
        }
        
        // 保存到 keychain
        do {
            let authManagerData = try JSONEncoder().encode(api.authorizationManager)
            keychain[data: authorizationManagerKey] = authManagerData
            print("SpotifyAuthManager: 已保存授权信息到 keychain")
        } catch {
            print("SpotifyAuthManager: 保存授权信息到 keychain 失败: \(error)")
        }
    }
    
    private func authorizationManagerDidDeauthorize() {
        withAnimation {
            isAuthorized = false
        }
        
        currentUser = nil
        
        do {
            try keychain.remove(authorizationManagerKey)
            print("SpotifyAuthManager: 已从 keychain 移除授权信息")
        } catch {
            print("SpotifyAuthManager: 从 keychain 移除授权信息失败: \(error)")
        }
    }
    
    // MARK: - User Info
    private func retrieveCurrentUser() {
        guard isAuthorized else { return }
        
        api.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("SpotifyAuthManager: 获取用户信息失败: \(error)")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    print("SpotifyAuthManager: 成功获取用户信息")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Debug
    func printAuthState() {
        print("SpotifyAuthManager 当前状态:")
        print("- isAuthorized: \(isAuthorized)")
        print("- authError: \(authError ?? "nil")")
        print("- currentUser: \(currentUser?.displayName ?? "nil")")
        print("- api authorized: \(api.authorizationManager.isAuthorized())")
    }
} 
