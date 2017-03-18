conn = new Mongo();
db = conn.getDB("org");

cursor = db.headings.find({"content": {$regex: "EF133EB9"}});
while ( cursor.hasNext() ) {
    var doc = cursor.next()
    printjson( doc.title );
}
