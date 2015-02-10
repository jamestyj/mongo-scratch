db = connect('localhost:27017/test_preallocate');

db.dropDatabase()
db.setProfilingLevel(2)

db.test.insert({
    _id : ObjectId("521f09cabfe2960b825f4aae"),
    u   : [ ObjectId("51da467de7cf66075d756166"), ObjectId("51950d1addb1b953f8bc1710") ],
    uid : "04b11e51be8c1b49d2686dfd6f0f0f84acd262d4",
    fv  : true,
    sv  : null,
    fvt : ISODate("2013-08-29T08:43:54.970Z"),
    svt : ISODate("0000-00-00T00:00:00.000Z")
})


db.test.update(
    { _id: ObjectId("521f09cabfe2960b825f4aae") },
    { $set: {
        sv: false,
        svt: ISODate("2013-08-29T09:43:54.970+-100")
      }
    }
)

cursor = db.system.profile.find({ ns: 'test_preallocate.test', op: 'update' }).sort({ ts: 1})
profile = cursor.next()

if (profile.moved) {
    print("BAD: Document moved!")
}
else {
    print("GOOD: In-place update")
}

db.setProfilingLevel(0)
