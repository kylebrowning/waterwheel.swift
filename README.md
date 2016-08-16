
![Waterwheel - Drupal SDK](https://raw.githubusercontent.com/acquia/waterwheel-swift/assets/waterwheel.png)

<p align='right'>
[![Drupal version](https://img.shields.io/badge/Drupal-8-blue.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/v/waterwheel.svg?maxAge=43000)]()
[![CocoaPods](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-green.svg)](#)
<br clear='all'/>

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#custom-types">Custom types</a> &bull;
    <a href="#traditional-api">Traditional API</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#more-like-this">More info</a>
</p>
-------

## Introduction

The Waterwheel Swift SDK is a set of classes that connects Drupal with Swift on any Apple powered device (iOS, macOS, watchOS, tvOS). It combines the most used commands to communicate with Drupal, gives you commons Views and tasks for Drupal apps, and handles all session management for you. 

The framework is tracking Drupal 8. As new features come out in 8, they will be added ASAP. Since Drupal 7 and Drupal 8 are completely different in terms of API's, you will need to use the correct version of waterwheel depending on your Drupal version.

Formerly known as Drupal iOS SDK.

<p align="center">
    <a href="#features-in-4x">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#Requirements">Requirements</a> &bull;
    <a href="#installation">Installation</a> &bull; 
    <a href="#more-like-this">More info</a>
</p>
-------

## Requirements
- iOS 8.0+ / Mac OS X 10.9+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 7.3+

| waterwheel version | Drupal version   |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [4.x](https://github.com/kylebrowning/waterwheel-swift/tree/4.x)         |            Drupal 8 (Swift)            | 
|          [3.x](https://github.com/kylebrowning/waterwheel-swift/tree/3.x)         |            Drupal 8 (Obj-C)                   |  |
|          [2.x](https://github.com/kylebrowning/waterwheel-swift/tree/2.x)         |            Drupal 6-7 (Obj-C)              |        Requires [Services](http://drupal.org/project/services) module                                                                    |
## Features in 4.x
- [x] Session management
- [x] Basic Auth
- [x] Cookie Auth
- [x] Entity CRUD
- [ ] True entities
- [ ] Local caching
- [x] LoginViewController
- [ ] SignupViewController
- [x] AuthButton
- [ ] Views integration into Table Views

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/waterwheel-swift). (Tag 'waterwheel-swift')
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Configuration

1. `import waterwheel`
2. (Optional) If you're not using HTTPS you will have to enable the [NSAppTransportSecurity](http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http)


## Usage

The code below will give you access to the baseline of features for communicating to a Drupal site.
```swift
// Sets the URL to your Drupal site.
waterwheel.setDrupalURL("http://drupal-8-2-0-beta1.dd")
```

The code below will set up Basic Authentication for each API call.
```swift
// Sets HTTPS Basic Authentication Credentials.
waterwheel.setBasicAuthUsernameAndPassword("test", password: "test2");
```

### Node Methods


### Get

```swift
// Get Node 36
waterwheel.nodeGet(nodeId: "36", params: nil, completionHandler: { (success, response, json, error) in
  print(response)
})
```

### Create/post

```swift
//build our node body
let body = [
    "type": [
        [
            "target_id": "article"
        ]
    ],
    "title": [
        [
            "value": "Hello World"
        ]
    ],
    "body": [
        [
            "value": "How are you?"
        ]
    ]
]

// Create a new node.
waterwheel.entityPost(entityType: .Node, params: body) { (success, response, json, error) in
    if (success) {
        print(response)
    } else {
        print(error)
    }
}
 ```

### Update/Put/PATCH

```swift
// Update an existing node
waterwheel.nodePatch(nodeId: "36", node: body) { (success, response, json, error) in
    print(response);
}
```

### Delete
```swift
// Delete an existing node
waterwheel.nodeDelete(nodeId: "36", params: nil, completionHandler: { (success, response, json, error) in
    print(response)
})
```

## Entity Requests
Since Node is rather specific, Watherweel provides entity methods as well for all entityTypes

### Entity Get

```swift
waterwheel.entityGet(entityType: .Node, entityId: "36", params: params, completionHandler: completionHandler)
```

### Entity Post

```swift
waterwheel.sharedInstance.entityPost(entityType: .Node, params: node, completionHandler: completionHandler)
```

### Entity Patch

```swift
waterwheel.entityPatch(entityType: .Node, entityId: "36", params: nodeObject, completionHandler: completionHandler)
```

### Entity Delete

```swift
waterwheel.entityDelete(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
```

### Auth Button / Login View Controller

```swift

waterwheel.setDrupalURL("http://drupal-8-2-0-beta1.dd")

let button = waterwheelAuthButton()
// When we press Login, lets show our Login view controller.
button.didPressLogin = {
    let vc = waterwheelLoginViewController()
    vc.loginRequestCompleted = { (success, error) in
        if (success) {
            // Do something related to a successfull login
            print("successfull login")
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            print (error)
        }
    }
    vc.logoutRequestCompleted = { (success, error) in
        if (success) {
            print("successfull logout")
            // Do something related to a successfull logout
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            print (error)
        }
    }
    // Lets Present our Login View Controller since this closure is for the button press
    self.presentViewController(vc, animated: true, completion: nil)
}

button.didPressLogout = { (success, error) in
    print("logged out")
}

self.view.addSubviews(button)
```
