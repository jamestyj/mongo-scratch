import com.mongodb.*;

import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Random;

public class MongoDB_HA_ReadWrites {

    private static void print(Object message) {
        SimpleDateFormat sdf = new SimpleDateFormat("hh:mm:ss.SSS");
        System.out.println(sdf.format(System.currentTimeMillis()) + ": " + message);
    }

    private static void ha_reads(MongoClient mongoClient, DBCollection collection) throws InterruptedException {
        // Change read preference from the default "primary" to "primaryPreferred"
        mongoClient.setReadPreference(ReadPreference.primaryPreferred());

        // Insert a simple document for testing reads later
        collection.insert(new BasicDBObject("a", 1));

        while (true) {
            try {
                print(collection.findOne());
            } catch (MongoException exception) {
                print("Can't connect to MongoDB");
                Thread.sleep(1000);
            }
        }
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

        // Connect to MongoDB replica set with seed list
        MongoClient mongoClient = new MongoClient(Arrays.asList(
                new ServerAddress("localhost", 27017),
                new ServerAddress("localhost", 27018),
                new ServerAddress("localhost", 27019)));

        DBCollection collection = mongoClient.getDB("test").getCollection("mongo_java");

//        ha_reads(mongoClient, collection);
        ha_writes(mongoClient, collection);
    }

}