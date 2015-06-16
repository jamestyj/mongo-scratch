import com.mongodb.*;
import com.mongodb.client.MongoCollection;
import org.bson.Document;

import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Random;

public class FT_readwrites {

    static final int MAX_RETRIES = 3;

    private static void print(Object message) {
        SimpleDateFormat sdf = new SimpleDateFormat("hh:mm:ss.SSS");
        System.out.println(sdf.format(System.currentTimeMillis()) + ": " + message);
    }

    public static void main(String[] args) throws UnknownHostException, InterruptedException {
        MongoClientOptions mongoOpts = MongoClientOptions.builder()
                .readPreference(ReadPreference.primaryPreferred())
                .connectTimeout(100)
                .serverSelectionTimeout(100)
                .build();
        MongoClient mongoClient = new MongoClient(
                Arrays.asList(
                        new ServerAddress("localhost", 27017),
                        new ServerAddress("localhost", 27018),
                        new ServerAddress("localhost", 27019)
                ),
                mongoOpts
        );

        // use test
        // db.ha_readwrites.
        MongoCollection collection = mongoClient.getDatabase("test").getCollection("ha_readwrites");

        while (true) {
            // Fault-tolerant writes
            for (int retries = 1; retries < MAX_RETRIES + 1; retries++) {
                try {
                    // db.ha_readwrites.insert({a:1})
                    collection.insertOne(new Document().append("a", 1));
                    print("Doc inserted (attempt #" + retries + ")");
                    break;
                } catch (MongoException ex) {
                    print("[ERROR] Doc insert failed (attempt #" + retries + "): " + ex.getMessage());
                    Thread.sleep(1000 + new Random().nextInt(4000));   // spread retries
                }
            }

            // Read a doc
            try {
                // db.ha_readwrites.findOne()
                print("Doc read: " + collection.find().first());
            } catch (MongoException ex) {
                print("[ERROR] Doc read failed: " + ex.getMessage());
            }

            Thread.sleep(1000);    // throttle our reads & writes
        }
    }

}