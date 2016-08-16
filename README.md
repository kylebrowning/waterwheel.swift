
![Waterwheel - Drupal SDK](https://raw.githubusercontent.com/acquia/waterwheel-swift/assets/waterwheel.png)

[![Drupal version](https://img.shields.io/badge/Drupal-8-blue.svg)]()
[![CocoaPods](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-green.svg)](#)
[![CocoaPods](https://img.shields.io/cocoapods/v/waterwheel.svg?maxAge=43000)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage)
![Swift version](https://img.shields.io/badge/swift-2.2%20|%202.3-orange.svg)

#### Waterwheel Swift SDK for `Drupal`
###### Waterwheel makes using Drupal as a backend with iOS, macOS, tvOS, or watchOS enjoyable by combining the most used features of Drupal's API's in one SDK. - Formerly known as Drupal iOS SDK.


-------
<p align="center">
    <a href="#features-in-4x">Features</a> &bull;
    <a href="#configuration">Configuration</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#requirements">Requirements</a>
</p>
-------

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

<a href="#">Back to Top</a>

## Configuration

1. `import waterwheel`
2. (Optional) If you're not using HTTPS you will have to enable the [NSAppTransportSecurity](http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http)


## Usage

The code below will give you access to the baseline of features for communicating to a Drupal site.
```swift
// Sets the URL to your Drupal site.
waterwheel.setDrupalURL("http://drupal-8-2-0-beta1.dd")
```

If is important to note that waterwheel makes heavy uses of [Closures](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html), which allows us to pass functions as returns, or store them in variables.

#### Login 

The code below will set up Basic Authentication for each API call.
```swift
// Sets HTTPS Basic Authentication Credentials.
waterwheel.setBasicAuthUsernameAndPassword("test", password: "test2");
```

If you do not want to use Basic Auth, and instead use a cookie, waterwheel provides an authentication method for doing so.
Sessions are handled for you, and will restore state upon closing an app and reopening it.
```swift
waterwheel.login(usernameField.text!, password: passwordField.text!) { (success, response, json, error) in
    if (success) {
        print("logged in")
    } else {
        print("failed to login")
    }
    self.loginRequestCompleted(success: success, error: error)
}
```

Waterwheel  provides a button to place anywhere in your app. The code below is iOS specific because of its dependence on UIKit. 

```swift
let loginButton = waterwheelAuthButton()
// When we press Login, lets show our Login view controller.
loginButton.didPressLogin = {
    let vc = waterwheelLoginViewController()
    // Lets Present our Login View Controller since this closure is for the loginButton press
    self.presentViewController(vc, animated: true, completion: nil)
}

loginButton.didPressLogout = { (success, error) in
    print("logged out")
}
self.view.addSubview(loginButton)
```

Taking this one step furthure, waterwheel also provides a LoginViewController. You can subclass this controller and overwrite it however you want. For our purposes we will use the default implementation.

```swift
let loginButton = waterwheelAuthButton()
// When we press Login, lets show our Login view controller.
loginButton.didPressLogin = {
    // Lets build our default waterwheelLoginViewController.
    let vc = waterwheelLoginViewController()
    //Lets add our function that will be run when the request is completed.
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
    // Lets Present our Login View Controller since this closure is for the loginButton press
    self.presentViewController(vc, animated: true, completion: nil)
}

loginButton.didPressLogout = { (success, error) in
    print("logged out")
}
self.view.addSubview(loginButton)

```

Because these two items know whether you are logged in or out, they will always show the correct state of buttons. The UI is up to you, but at its default you get username, password and submit button.


### Node Methods


#### Get

```swift
// Get Node 36
waterwheel.nodeGet(nodeId: "36", params: nil, completionHandler: { (success, response, json, error) in
  print(response)
})
```

#### Create/post

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

#### Update/Put/PATCH

```swift
// Update an existing node
waterwheel.nodePatch(nodeId: "36", node: body) { (success, response, json, error) in
    print(response);
}
```

#### Delete
```swift
// Delete an existing node
waterwheel.nodeDelete(nodeId: "36", params: nil, completionHandler: { (success, response, json, error) in
    print(response)
})
```

## Entity Requests
Since Node is rather specific, Watherweel provides entity methods as well for all entityTypes

#### Entity Get

```swift
waterwheel.entityGet(entityType: .Node, entityId: "36", params: params, completionHandler: completionHandler)
```

#### Entity Post

```swift
waterwheel.sharedInstance.entityPost(entityType: .Node, params: node, completionHandler: completionHandler)
```

### Entity Patch

```swift
waterwheel.entityPatch(entityType: .Node, entityId: "36", params: nodeObject, completionHandler: completionHandler)
```

#### Entity Delete

```swift
waterwheel.entityDelete(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
```
## Installation

Waterwheel offers two installations paths. Pick your poison!

## Installation

#### CocoaPods

If you're using CocoaPods, just add this line to your Podfile:

```ruby
pod 'waterwheel'
```

Install by running this command in your terminal:

```sh
pod install
```

Then import the library in all files where you use it:

```swift
import waterwheel
```

#### Carthage

Just add to your Cartfile:

```ruby
github "acquia/waterwheel-swift"
```
Run `carthage update` to build the framework and drag the built `waterwheel.framework` into your Xcode project.

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/waterwheel-swift). (Tag 'waterwheel-swift')
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

<a href="#">Back to Top</a>



## Drupal Compatibility

#### The framework is tracking Drupal 8. As new features come out in 8, they will be added ASAP. Since Drupal 7 and Drupal 8 are completely different in terms of API's, you will need to use the correct version of waterwheel depending on your Drupal version.



## Requirements
- iOS 8.0+ / Mac OS X 10.9+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 7.3+

| waterwheel version | Drupal version   |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [4.x](https://github.com/kylebrowning/waterwheel-swift/tree/4.x)         |            Drupal 8 (Swift)            | 
|          [3.x](https://github.com/kylebrowning/waterwheel-swift/tree/3.x)         |            Drupal 8 (Obj-C)                   |  |
|          [2.x](https://github.com/kylebrowning/waterwheel-swift/tree/2.x)         |            Drupal 6-7 (Obj-C)              |        Requires [Services](http://drupal.org/project/services) module                                                                    |

<a href="#">Back to Top</a>
