//import org.bson.types.ObjectId;
//import org.mongodb.morphia.Key;
//import org.mongodb.morphia.annotations.*;
//
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.List;
//
//// Use "noClassnameStored = true" to avoid storing the unnecessary "className" field.
//@Entity(value = "employees", noClassnameStored = true)
//class Employee {
//    // auto-generated, if not set (see ObjectId)
//    @Id ObjectId id;
//
//    // value types are automatically persisted
//    String firstName, lastName;
//
//    // only non-null values are stored
//    @Indexed
//    Long salary = null;
//
//    // by default fields are @Embedded
////    Address address;
//
//    //references can be saved without automatic loading
//    Key<Employee> manager;
//
//    //refs are stored**, and loaded automatically
//    @Reference List<Employee> underlings = new ArrayList<Employee>();
//
//    // stored in one binary field
////    @Serialized EncryptedReviews;
//
//    //fields can be renamed
//    @Property("started") Date startDate;
//    @Property("left")    Date endDate;
//
//    //fields can be indexed for better performance
//    @Indexed boolean active = false;
//
//    //fields can loaded, but not saved
//    @NotSaved String readButNotStored;
//
//    //fields can be ignored (no load/save)
//    @Transient int notStored;
//
//    //not @Transient, will be ignored by Serialization/GWT for example.
//    transient boolean stored = true;
//
//    //Lifecycle methods -- Pre/PostLoad, Pre/PostPersist...
////    @PostLoad void postLoad(DBObject dbObj) { ... }
//}