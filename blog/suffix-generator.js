// Script for generating random docs to compare relative performance of various
// search techniques (partial keywords).
//
// Author: James Tan <james.tan@mongodb.com>

var Generator = function() {

    this.setDefaults = function() {
        if (typeof THREADS    === 'undefined') THREADS    = 4;
        if (typeof BATCH_SIZE === 'undefined') BATCH_SIZE = 2000;
        if (typeof COUNT      === 'undefined') COUNT      = 100;
        if (typeof COLL_NAME  === 'undefined') COLL_NAME  = 'items';
        print('THREADS    =', THREADS);
        print('BATCH_SIZE =', BATCH_SIZE);
        print('COUNT      =', COUNT);
        print('COLL_NAME  =', COLL_NAME, "\n");
    };

    this.createIndex = function(coll, idx) {
        print('Creating index:');
        printjson(idx);
        var timer = new this.Timer();
        db[coll].ensureIndex(idx);
        print('Took', timer.elapsed(), "\n");
    };

    this.progressReporter = function(collection_name, total_docs) {
        var POLL_INTERVAL_SECS = 1;
        var loops = 0;
        while (typeof count === 'undefined' || count<total_docs) {
            sleep(POLL_INTERVAL_SECS*1000);
            loops += 1;
            var count = db[collection_name].count();
            print((count/total_docs*100).toFixed(2) + '%',
                  '(' + (count/(POLL_INTERVAL_SECS*loops)).toFixed(0) + ' inserts/sec)');
        }
    };

    this.insertDocs = function(collection_name, count, batch) {
        this.makeSuffixes = function(values) {
            var results = [];
            values.sort().reverse().forEach(function(val) {
                var tmp, hasSuffix;
                for (var i=0; i<val.length-2; i++) {
                    tmp = val.substr(i).toUpperCase();
                    hasSuffix = false;
                    for (var j=0; j<results.length; j++) {
                        if (results[j].indexOf(tmp) === 0) {
                            hasSuffix = true;
                            break;
                        }
                    }
                    if (!hasSuffix) results.push(tmp);
                }
            });
            return results;
        };

        this.randomStr = function(length) {
            var str   = '';
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (var i=0; i<length; i++) {
                str += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            return str;
        };

        var docs, a, b;
        for (var i=0; i<count; i++) {
            docs = [];
            for (var j=0; j<batch; j++) {
                a = this.randomStr(8);
                b = this.randomStr(8);
                docs.push({ keys: [a,b], suffixes: this.makeSuffixes([a,b]) });
            }
            db[collection_name].insert(docs);
        }
    };

    this.Timer = function() {
        this.elapsed = function() {
            var secs = Math.floor(((new Date().getTime()) - this._start)/1000);
            var hrs  = Math.floor(secs/3600);
            var mins = Math.floor((secs%3600)/60);
                secs = Math.floor(secs%3600%60);
            if (secs < 10) secs = '0' + secs;
            if (mins < 10) mins = '0' + mins;
            if (hrs  < 10) hrs  = '0' + hrs;
            return ((hrs == 0) ? [ mins, secs ] : [ hrs, mins, secs ]).join(':');
        };
        this._start = new Date().getTime();
    };

    this.enableThreading = function() {
        if (typeof _threadInject !== 'undefined') {
            Thread = function() { this.init.apply(this, arguments); };
            _threadInject(Thread.prototype);
        }
    };

    this.generateDocs = function() {
      db[COLL_NAME].drop();
      print('Dropped collection');

      var total_docs = THREADS*BATCH_SIZE*COUNT;
      print('Inserting', total_docs, 'docs...');

      // Start insert threads
      var threads = [], t;
      var timer = new this.Timer();
      for (var i=0; i<THREADS; i++) {
          t = new Thread(this.insertDocs, COLL_NAME, COUNT, BATCH_SIZE);
          t.start();
          threads.push(t);
      }

      // Start progress reporting thread
      t = new Thread(this.progressReporter, COLL_NAME, total_docs);
      t.start();
      threads.push(t);

      // Wait for all threads to finish
      threads.forEach(function(t) { t.join(); });
      print('Took', timer.elapsed(), "\n");
    };

    this.enableThreading();
    this.setDefaults();
    this.generateDocs();
    this.createIndex(COLL_NAME, { keys:     1 });
    this.createIndex(COLL_NAME, { suffixes: 1 });
};

new Generator();
