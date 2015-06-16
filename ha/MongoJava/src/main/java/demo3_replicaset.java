import com.mongodb.*;

import java.net.UnknownHostException;
import java.util.Arrays;

public class demo3_replicaset {

    public static void main(String[] args) throws UnknownHostException {
        // Connect to replica set
        MongoClient mongoClient = new MongoClient(
                Arrays.asList(
                        new ServerAddress("localhost", 27017),
                        new ServerAddress("localhost", 27018),
                        new ServerAddress("localhost", 27019)
                )
        );

        // Change read preference from the default "primary" to "primaryPreferred"
        mongoClient.setReadPreference(ReadPreference.primaryPreferred());

        // Change write concern from default "w: 1" to "w: majority"
        mongoClient.setWriteConcern(WriteConcern.MAJORITY);
    }

}