import com.mongodb.*;

import java.net.UnknownHostException;
import java.util.Arrays;

public class demo4_options {

    public static void main(String[] args) throws UnknownHostException {
        // Additional options
        MongoClientOptions options = MongoClientOptions.builder()
                .connectTimeout(50)
                .socketTimeout(100)
                .readPreference(ReadPreference.primaryPreferred())
                .writeConcern(WriteConcern.MAJORITY)
                .build();

        MongoClient mongoClient = new MongoClient(
                Arrays.asList(
                        new ServerAddress("localhost", 27017),
                        new ServerAddress("localhost", 27018),
                        new ServerAddress("localhost", 27019)
                ),
                options
        );
    }

}