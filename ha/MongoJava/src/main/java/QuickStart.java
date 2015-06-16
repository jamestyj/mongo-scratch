import com.mongodb.*;

import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Random;
import java.util.Set;

public class QuickStart {

    private static void print(Object message) {
        SimpleDateFormat sdf = new SimpleDateFormat("hh:mm:ss.SSS");
        System.out.println(sdf.format(System.currentTimeMillis()) + ": " + message);
    }

    private static void ha_writes(MongoClient mongoClient, DBCollection collection) throws InterruptedException {
        // http://api.mongodb.org/java/current/com/mongodb/WriteConcern.html
        mongoClient.setWriteConcern(WriteConcern.majorityWriteConcern(0, false, true));

        int retries = 0;
        while (true) {
            try {
                collection.insert(new BasicDBObject("a", 1));
                print("Inserted document");
            } catch (MongoException exception) {
                print("Can't connect to MongoDB");

                if (retries >= 100) {
                    print("Retried more than 100 times, giving up!");
                    break;
                }

                // Wait for 1 to 5 seconds to spread out retries
                Thread.sleep(1000 + new Random().nextInt(4000));
                retries++;
            }
        }
    }

    public static void main(String[] args) throws UnknownHostException, InterruptedException {
        MongoClient mongoClient = new MongoClient(Arrays.asList(
                new ServerAddress("localhost", 27017),
                new ServerAddress("localhost", 27018)));

        DB db = mongoClient.getDB("mongojava");
        Set<String> colls = db.getCollectionNames();

        for (String s : colls) {
            System.out.println(s);
        }

        DBCollection coll = db.getCollection("test");
//        mongoClient.setWriteConcern(WriteConcern.JOURNALED);

//        { "_id": ObjectId("52ffa42f8de26d737cbacd6e"),
//          "name": "MongoDB",
//          "type": "database",
//          "count": 1,
//          "info": { "x": 203, "y": 102 }
//        }

//        BasicDBObject doc = new BasicDBObject("name", "MongoDB").
//                append("type", "database").
//                append("count", 1).
//                append("info", new BasicDBObject("x", 203).append("y", 102));

//        coll.insert(doc);
        DBObject myDoc = coll.findOne();
        System.out.println(myDoc);

        ha_writes(mongoClient, coll);
    }

}