// http://java.dzone.com/articles/mongodb-message-queue
// Easily extended to support multiple and priority queues

// Enqueue incoming jobs
db.queue.drop()
for (var i=0; i<5; i++) {
  db.queue.insert({ job: 'do somehing', ts: new Date(), state: "NEW" })
}

// Create index
db.queue.ensureIndex({ state: 1, ts: 1 })

// Atomically dequeue a job for processing
doc = db.queue.findAndModify({
  query : { state: "NEW" },
  sort  : { ts: 1 },
  update: {
    $set: { state: "PROCESSING", worker: "host1234", ts: new Date() },
  },
  new: true
})

// Process job...
// Atomically update job state when done
db.queue.update(
  { _id: doc._id, state: "PROCESSING" },
  { $set: { state: "DONE", ts: new Date() } }
)

// Atomically dequeue a job for processing
doc = db.queue.findAndModify({
  query : { state: "NEW" },
  sort  : { ts: 1 },
  update: {
    $set: { state: "PROCESSING", worker: "host1234", ts: new Date() },
  },
  new: true
})

// Check for stale/hung jobs (cron job)
THRESHOLD_IN_HOURS = 0
date = new Date()
date.setHours(date.getHours() - THRESHOLD_IN_HOURS)
db.queue.find({ state: "PROCESSING", ts: { $lt: date } })
  .forEach(function(job) {
    // Check job state on worker host
    // Re-queue job by resetting job state to NEW
    db.queue.update(
      { _id: job._id, state: "PROCESSING" },
      { $set: { state: "NEW", ts: new Date() } }
    )
  }
)

// Remove old jobs (cron job)
THRESHOLD_IN_DAYS = 0
date = new Date()
date.setDate(date.getDate() - THRESHOLD_IN_DAYS)
bulk = db.queue.initializeUnorderedBulkOp()
db.queue.find({ state: "DONE", ts: { $lt: date } })
  .forEach(function(job) {
    bulk.find({ _id: job._id }).removeOne()
  }
)
bulk.execute()
