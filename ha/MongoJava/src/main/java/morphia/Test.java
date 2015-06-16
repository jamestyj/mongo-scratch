//package morphia;
//
//import com.mongodb.Mongo;
//import com.mongodb.MongoClient;
//import org.mongodb.morphia.Datastore;
//import org.mongodb.morphia.Morphia;
//
//import java.net.UnknownHostException;
//import java.util.ArrayList;
//import java.util.Date;
//
//public class Test {
//
//    private static void create(Datastore ds) {
//        ds.getCollection(BlogEntry.class).drop();
//
//        Author author       = new Author();
//        author.username     = "jamestyj";
//        author.fullName     = "James Tan";
//        author.emailAddress = "jamestyj@gmail.com";
//        ds.save(author);
//
//        BlogEntry blogEntry   = new BlogEntry();
//        blogEntry.publishDate = new Date();
//        blogEntry.title       = "2nd post";
//        ds.save(blogEntry);
//
//        BlogEntry blogEntry2   = new BlogEntry();
//        blogEntry2.publishDate = new Date();
//        blogEntry2.title       = "3rd post";
//        ds.save(blogEntry2);
//
//        BlogEntry blogEntry3   = new BlogEntry();
//        blogEntry3.publishDate = new Date();
//        blogEntry3.title       = "First post";
//        blogEntry3.body        = "Very excited to have my first post....";
//        blogEntry3.subposts    = new ArrayList<BlogEntry>();
//        blogEntry3.subposts.add(blogEntry);
//        blogEntry3.subposts.add(blogEntry2);
//        ds.save(blogEntry3);
//    }
//
//    public static void main(String[] args) throws UnknownHostException {
//        Morphia morphia   = new Morphia();
//        morphia.map(BlogEntry.class);
//
//        Datastore ds = morphia.createDatastore(new MongoClient(), "morphia");
//        ds.ensureIndexes();
//
//        create(ds);
//
//        BlogEntry blogEntry = ds.find(BlogEntry.class).field("title").equal("First post").get();
//        for (BlogEntry entry : blogEntry.subposts) {
//            System.out.println(entry);
//        }
//
////        for (Employee emp : ds.createQuery(Employee.class).asList()) {
////            System.out.println(emp);
////        }
//    }
//}