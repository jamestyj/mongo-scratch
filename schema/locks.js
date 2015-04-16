// Create locks
db.locks.drop()
db.locks.insert({ _id: "lock1", locked: false, ts: new Date() })
db.locks.insert({ _id: "lock2", locked: false, ts: new Date() })
db.locks.insert({ _id: "lock3", locked: false, ts: new Date() })

function getLock(lock_name) {
    // MongoDB 2.6 and above returns the WriteResult document, which tells us
    // how many documents were updated. Prior versions should use
    // findAndModify() instead.
    return db.locks.update(
        { _id: lock_name, locked: false },
        { $set: { locked: true, ts: new Date() } }
    )
}

function releaseLock(lock_name) {
    return db.locks.update(
        { _id: lock_name },  // TODO: consider adding locked: true and check for errors
        { $set: { locked: false, ts: new Date() } }
    )
}

function runCriticalSection(lock_name) {
    // Spin loop while waiting for the lock
    while (getLock(lock_name).nModified === 0) {
        print("Waiting for lock...")
        sleep(500)
    }
    print("Got lock")
    print("Processing critical section...")
    print("Releasing lock")
    releaseLock(lock_name)
}

// Simulate other thread holding the lock
var lock_name = "lock1"
getLock(lock_name)

// Release stale locks after timeout (cron job)
THRESHOLD_IN_MINS = 1
date = new Date()
date.setMinutes(date.getMinutes() - THRESHOLD_IN_MINS)  // TODO: Check that this works for 00 minutes
db.locks.update(
    { locked: true, ts: { $lt: date } },
    { $set: { locked: false } }
)
