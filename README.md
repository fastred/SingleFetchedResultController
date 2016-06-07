# SingleFetchedResultController
Like NSFetchedResultsController but for a single managed object.

## Usage

```swift
class MyClass {
    var frc: SingleFetchedResultController<Profile>?
    ...
    
    func setup() throws {
        let predicate = NSPredicate(format: "username = %@", username)
        frc = SingleFetchedResultController(predicate: predicate,
                                            managedObjectContext: moc,
                                            onChange: { (profile, changeType) in
            // will be called after the first fetch and after each change to the object
            print(profile.username)
        })
    
        try frc?.performFetch()
    }
}
```

## Requirements

iOS 8 and above.

## Author

Arkadiusz Holko:

* [@arekholko on Twitter](https://twitter.com/arekholko)
* [Holko.pl](http://holko.pl/)

