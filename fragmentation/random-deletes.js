coll = db.frag

while (true) {
    coll.remove({}, { justOne: true })
}
