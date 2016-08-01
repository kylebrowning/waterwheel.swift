#Drupal Swit SDK - Connect your iOS, macOS, watchOS, tvOS app to Drupal

##### built by [Kyle Browning](http://kylebrowning.com) 


##Introduction

The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple, and is basically a wrapper for Alamofire. It combines the most used commands to communicate with Drupal and handles session managment for you.

## Requirements

| DIOS Version | Drupal Version  | Min iOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [4.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/4.x)         |            Drupal 8 (Swift)            | iOS 9.0   
|          [3.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/master)         |            Drupal 8 (Obj-C)            |           iOS 7.0          |  |
|          [2.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/2.x)         |            Drupal 6-7 (Obj-C)            |         iOS 5.0        |        Requires [Services](http://drupal.org/project/services) module                                                                    |

## Philosophy and Purpose
At its core the Drupal Swift SDK is designed to handle everything Drupal Core supports out of the box. Since 8.x is in its infancy, more and more features will come available as Drupal aims to improve its API capabilities.

## Current 4.x features
- Session management
- Entity Crud
 
## Future
In the future this project will have more robust features that make working with Drupal from a Swift perspective easier such as:

- LoginViewController
- SignupViewController
- LogoutButton
- Views integration into Table Views

##Installation
----
Create a pod file with (this will keep you on the 4.0 releases which is Drupal 8 specific) 
```
 pod 'DIOS', '~> 4.0'
```
Then run 
```
pod install
```

##Configuration

1. Copy the plist file from this repository or make your own and called it `dios.plist`
2. Edit the `diosurlkey` to point to your domain
3. (Optional) If you're not using HTTPS you will have to enable the [NSAppTransportSecurity](http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http)


##Initialization Steps

The code below will give you access to the baseline of features for communicating to a Drupal site.
```swift 
//Create an instance to use.
let dios = DIOS.sharedInstance
```

This will log you into the site.
```swift
//set Username and password
dios.setUserNameAndPassword("kylebrowning", password: "password")
```

## Entity Requests

```swift
//we need an entity manager instance
let em = DIOSEntity()
```

### Get

```swift
let em = DIOSEntity()

//Get Node 36
em.get("node", entityId: "36") { (success, response, json, error) in
    if (success) {
        print(json)
    } else {
        print(error)
    }
}
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

//Create a new node.
em.post("node", params: body) { (success, response, json, error) in
    if (success) {
        print(response)
    } else {
        print(error)
    }
}
 ```
 
### Update/Put/PATCH

```swift
//Update an existing node
em.patch("node", entityId: "36", params: body) { (success, response, json, error) in
    if (success) {
        //Extra error checking, but its not needed
        if (response!.response?.statusCode == 201) {
            print(json)
        }
    } else {
        print(error)
    }
}
```

### Delete
```swift
//Delete an existing node
em.delete("node", entityId: "26") { (success, response, json, error) in
    if (success) {
        print(response)
    } else {
        print(error)
    }
}
```
