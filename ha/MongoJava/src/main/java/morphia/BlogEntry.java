//package morphia;
//
//import org.bson.types.ObjectId;
//import org.mongodb.morphia.annotations.Entity;
//import org.mongodb.morphia.annotations.Id;
//import org.mongodb.morphia.annotations.Reference;
//
//import java.util.Date;
//import java.util.List;
//
//@Entity(noClassnameStored = true)
//public class BlogEntry {
//
//    @Id
//    private ObjectId id;
//
//    String title;
//    Date   publishDate;
//    String body;
//
//    @Reference(idOnly = true)
//    List<BlogEntry> subposts;
//
//
//    public String toString() {
//        return id + ": " + title + "; " + publishDate.toString() + "; " + body;
//    }
//}