###Drupal iOS SDK - Connect your iOS/OS X app to Drupal
-----
###### built by [Kyle Browning](http://kylebrowning.com) 


####Introduction
----

The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple, and is basically a wrapper for AFNetworking. It combines the most used commands to communicate with Drupal and handles session managment for you(minus oauth)

### Requirements

| DIOS Version | Drupal Version  | Min iOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [4.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/4.x)         |            Drupal 8 (Swift)            | iOS 9.0   
|          [3.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/master)         |            Drupal 8 (Obj-C)            |           iOS 7.0          |  |
|          [2.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/2.x)         |            Drupal 6-7 (Obj-C)            |         iOS 5.0        |        Requires [Services](http://drupal.org/project/services) module                                                                    |


####Installation
----
Create a pod file with (this will keep you on the 4.0 releases which is Drupal 8 specific) 
```
 pod 'DIOS', '~> 4.0'
```
Then run 
```
pod install
```

####Configuration

`Coming soon`

####Usage

##Initialization Steps

```swift 
        // Do any additional setup after loading the view, typically from a nib.

        //get our shared instance
        let dios = DIOS.sharedInstance

        //set Username and password
        dios.setUserNameAndPassword("kylebrowning", password: "password")

        //get our Entity Manager
        let em = DIOSEntity()

        //Get Node 36
        em.get("node", entityId: "36") { (success, response, json, error) in
            if (success) {
                print(json)
            } else {
                print(error)
            }
        }


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

        //Delete an existing node
        em.delete("node", entityId: "26") { (success, response, json, error) in
            if (success) {
                print(response)
            } else {
                print(error)
            }
        }

        //Lets add a comment
        let comment_body = [
            "uid": [
                [
                    "target_id": 1
                ]
            ],
            "entity_id": [
                [
                    "target_id": 36
                ]
            ],
            "comment_body": [
                [
                    "value": "<p>See you later!</p>",
                    "format": "basic_html"
                ]
            ],
            "entity_type": [
                [
                    "value": "node"
                ]
            ],
            "subject": [
                [
                    "value": "Goodbye World"
                ]
            ],
            "comment_type": [
                [
                    "target_id": "comment"
                ]
            ],
            "field_name": [
                [
                    "value": "comment"
                ]
            ]
        ]

        //Create a comment
        em.create("comment", params: comment_body) { (success, response, json, error) in
            if (success) {
                print(response)
            } else {
                print(error)
            }
        }
    }
 ```
