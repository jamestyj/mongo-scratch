// http://docs.mongodb.org/manual/reference/method/db.collection.insert/

// Create document array
docs = []
for (i=0; i<5000; i++) {
    docs.push({ a: 1 })
}

// Batch insert
while (true) {
    db.foo.insert(docs)
}