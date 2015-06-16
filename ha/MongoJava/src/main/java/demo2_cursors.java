import com.mongodb.*;

import java.net.UnknownHostException;

public class demo2_cursors {

    public static void main(String[] args) throws UnknownHostException {
        MongoClient mongoClient = new MongoClient();
        DBCollection coll = mongoClient.getDB("test").getCollection("java");

        // db.java.findO()
        DBCursor cursor = coll.find();
        try {
            while (cursor.hasNext()) {
                System.out.println(cursor.next());
            }
        } finally {
            cursor.close();
        }
    }

}