// http://docs.mongodb.org/manual/reference/method/Bulk/#Bulk

doc  = { a: 1 }

print("Bulk inserting documents...")
while (true) {
    bulk = db.foo.initializeUnorderedBulkOp()
    for (i=0; i<5000; i++) {
        bulk.insert(doc)
    }
    bulk.execute()
}
