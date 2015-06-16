import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.MongoClient;

import java.net.UnknownHostException;

public class powerOf2Sizes {
    public static void main(String[] args) throws UnknownHostException {
        MongoClient mongoClient = new MongoClient();
        DB db = mongoClient.getDB("myDB");
        db.createCollection("myCollection", new BasicDBObject());
        BasicDBObject cmd = new BasicDBObject("collMod", "myCollection").append("usePowerOf2Sizes", true);
        db.command(cmd);
    }
}
