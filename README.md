# Decentralized Instant Messaging Client (Objective-C)

[![License](https://img.shields.io/github/license/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimpart/demo-objc/pulls)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20OSX%20%7C%20watchOS%20%7C%20tvOS-brightgreen.svg)](https://github.com/dimpart/demo-objc/wiki)
[![Issues](https://img.shields.io/github/issues/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/issues)
[![Repo Size](https://img.shields.io/github/repo-size/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/archive/refs/heads/master.zip)
[![Tags](https://img.shields.io/github/tag/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/tags)
[![Version](https://img.shields.io/cocoapods/v/DIMClient
)](https://cocoapods.org/pods/DIMClient)

[![Watchers](https://img.shields.io/github/watchers/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/watchers)
[![Forks](https://img.shields.io/github/forks/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/forks)
[![Stars](https://img.shields.io/github/stars/dimpart/demo-objc)](https://github.com/dimpart/demo-objc/stargazers)
[![Followers](https://img.shields.io/github/followers/dimpart)](https://github.com/orgs/dimpart/followers)

## Dependencies

* Latest Versions

| Name | Version | Description |
|------|---------|-------------|
| [Ming Ke Ming (名可名)](https://github.com/dimchat/mkm-objc) | [![Version](https://img.shields.io/cocoapods/v/MingKeMing)](https://cocoapods.org/pods/MingKeMing) | Decentralized User Identity Authentication |
| [Dao Ke Dao (道可道)](https://github.com/dimchat/dkd-objc) | [![Version](https://img.shields.io/cocoapods/v/DaoKeDao)](https://cocoapods.org/pods/DaoKeDao) | Universal Message Module |
| [DIMP (去中心化通讯协议)](https://github.com/dimchat/core-objc) | [![Version](https://img.shields.io/cocoapods/v/DIMCore)](https://cocoapods.org/pods/DIMCore) | Decentralized Instant Messaging Protocol |
| [DIM SDK](https://github.com/dimchat/sdk-objc) | [![Version](https://img.shields.io/cocoapods/v/DIMSDK)](https://cocoapods.org/pods/DIMSDK) | Software Development Kit |
| [DIM Plugins](https://github.com/dimchat/plugins-objc) | [![Version](https://img.shields.io/cocoapods/v/DIMPlugins)](https://cocoapods.org/pods/DIMPlugins) | Cryptography & Account Plugins |
| [Star Trek](https://github.com/moky/StarTrek) | [![Version](https://img.shields.io/cocoapods/v/StarTrek)](https://cocoapods.org/pods/StarTrek) | Network Connection Module |
| [State Machine](https://github.com/moky/FiniteStateMachine) | [![Version](https://img.shields.io/cocoapods/v/FiniteStateMachine)](https://cocoapods.org/pods/FiniteStateMachine) | Finite State Machine |

* Podfile

```
platform :ios, '12.0'

target 'DIMClient' do
    pod 'DIMSDK', '~> 1.0.9'
    pod 'DIMPlugins', '~> 1.0.9'
    pod 'StarTrek', '~> 0.1.3'
end
```

Copyright &copy; 2018-2025 Albert Moky
[![Followers](https://img.shields.io/github/followers/moky)](https://github.com/moky?tab=followers)
