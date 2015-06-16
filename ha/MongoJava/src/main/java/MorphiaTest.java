//import com.mongodb.Mongo;
//import com.mongodb.MongoClient;
//import org.mongodb.morphia.Datastore;
//import org.mongodb.morphia.Morphia;
//
//import java.net.UnknownHostException;
//import java.util.Date;
//
//public class MorphiaTest {
//
//    public static void main(String[] args) throws UnknownHostException {
//
//        Mongo mongoClient = new MongoClient();
//        Morphia morphia = new Morphia();
//        morphia.map(Employee.class);
//        Datastore ds = morphia.createDatastore(mongoClient, "morphia");
//        ds.ensureIndexes();
//
//        Employee employee = new Employee();
//        employee.firstName = "James";
//        employee.lastName  = "Tan";
//        employee.salary    = Long.valueOf(100000);
//        employee.startDate = new Date();
//        ds.save(employee);
//
//        for (Employee emp : ds.createQuery(Employee.class).asList()) {
//            System.out.println(emp);
//        }
//    }
//
//}