import com.mongodb.BasicDBObject;
import com.mongodb.DBCollection;
import com.mongodb.MongoClient;
import com.mongodb.WriteResult;

import java.net.UnknownHostException;

public class demo1_basics {

    public static void main(String[] args) throws UnknownHostException {
        // Connect to localhost:27017
        MongoClient mongoClient = new MongoClient();

        // use test (and collection "java")
        DBCollection coll = mongoClient.getDB("test").getCollection("java");

        // db.java.insert({ a: 1 })
        WriteResult res = coll.insert(new BasicDBObject("a", 1));
        System.out.println(res);

        // db.java.findOne()
        System.out.println(coll.findOne());
    }

}