/* Read arguments.  */
var args = Array.prototype.slice.call(process.argv, 2);
if (args.length !== 1) {
  console.log("Usage: createDictionary path/dictionary_file, [db_path/db_filename]|'../dev.sqlite3.db'");
  return
}
var dictFilename = args[0];
var dbFilename = args[1] || '../dev.sqlite3.db';

/* load db */
var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database(dbFilename);

/* load dictionary file */
var fs = require('fs')
console.log('Parsing dictionary: ', dictFilename);

/* assign letter values */
var getValue = function(word) {
  var values = {
    ' ': 0, 
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8, 'K': 5, 'L': 1, 'M': 3, 
    'N': 1, 'O': 1, 'P': 3, 'Q': 10, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 4, 'W': 4, 'X': 8, 'Y': 4, 'Z': 10
  };
  var value = 0;
  for(var i=0; i<word.length; i++) {
    value += values[word[i].toUpperCase()];
  }
 return value;
};

/* generate sql from the word, including point value and date of creation */
var createSql = function(word) {
  var d = new Date( Date.now() ).toLocaleString();
  var sql = "INSERT INTO dict (word, points) VALUES (";
  //sql += "'" + word + "', " + getValue(word) + ", 0,'" + d + "', '" + d + "');";
  sql += "'" + word + "', " + getValue(word) + ");";
  return sql;
};

var count = 0;
fs.readFile( dictFilename, 'utf8', function(err, data){
  if (err) {
    console.log('Got error reading file', dictFilename);
    db.close();
  } else {
    words = data.split('\n');    
    if (words[ words.length - 1 ] == '') {
      words.splice(words.length-1, 1);
    }
    count += words.length;
    console.log(count);
    if( words.length ) { 	
      words.forEach( function(word) { 
//        console.log( createSql(word) );

        db.serialize( function() {
  	      var stmt = db.prepare( createSql( word) );
  	      stmt.run();
  	      stmt.finalize();
        });
      });
    } else {
      console.log('All done!!');
      db.close();
    }
  }
});
