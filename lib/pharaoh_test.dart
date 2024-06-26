// import 'package:postgres/postgres' as conn;

import 'package:pharaoh/pharaoh.dart';
import 'package:postgres/postgres.dart';

final loggerMiddleware = (Request req, Response res, NextFunction next) {
  print(req.headers.entries.join('\n\n'));

  // final token = req.headers['Token'];

  // if (token == null) return next(res.unauthorized());
  next();
};
void main() async {
  final app = Pharaoh();

  final conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'postgres',
        username: 'postgres',
        password: 'postgres',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable));

  // print(conn.execute("SELECT 1"));
  // final result = await conn.execute("SELECT 'foo'");
  // print(result[0][0]); // first row and first field

  // final loggerMiddleware = (Request req, Response res, NextFunction next) {
  //   print(req.headers);

  //   next();
  // }
  print('has connection!');

  // Simple query without results
  // await conn.execute('CREATE TABLE IF NOT EXISTS a_table ('
  //     '  id TEXT NOT NULL, '
  //     '  totals INTEGER NOT NULL DEFAULT 0'
  //     ')');

  // // simple query
  // final result0 = await conn.execute("SELECT 'foo'");
  // print(result0[0][0]); // first row, first column

  // // Using prepared statements to supply values
  // final result1 = await conn.execute(
  //   r'INSERT INTO a_table (id) VALUES ($1)',
  //   parameters: ['example row'],
  // );
  // print('Inserted ${result1.affectedRows} rows');

  // // name parameter query
  // final result2 = await conn.execute(
  //   Sql.named('SELECT * FROM a_table WHERE id=@id'),
  //   parameters: {'id': 'example row'},
  // );
  // print(result2.first.toColumnMap());

  await conn.execute('CREATE TABLE IF NOT EXISTS a_table ('
      '  id TEXT NOT NULL, '
      '  totals INTEGER NOT NULL DEFAULT 0'
      ')');

  // simple query
  final result0 = await conn.execute("SELECT 'foo'");
  print(result0[0][0]); // first row, first column

  // Using prepared statements to supply values
  final result1 = await conn.execute(
    r'INSERT INTO a_table (id) VALUES ($1)',
    parameters: ['example row'],
  );
  print('Inserted ${result1.affectedRows} rows');

  // name parameter query
  final result2 = await conn.execute(
    Sql.named('SELECT * FROM a_table WHERE id=@id'),
    parameters: {'id': 'example row'},
  );
  print(result2.first.toColumnMap());

  // transaction
  await conn.runTx((s) async {
    final rs = await s.execute('SELECT count(*) FROM a_table');
    await s.execute(
      r'UPDATE a_table SET totals=$1 WHERE id=$2',
      parameters: [rs[0][0], 'xyz'],
    );
  });

  // prepared statement
  final statement = await conn.prepare(Sql("SELECT 'foo';"));
  final result3 = await statement.run([]);
  print(result3);
  await statement.dispose();

  // preared statement with types
  final anotherStatement =
      await conn.prepare(Sql(r'SELECT $1;', types: [Type.bigInteger]));
  final bound = anotherStatement.bind([1]);
  final subscription = bound.listen((row) {
    print('row: $row');
  });
  await subscription.asFuture();
  await subscription.cancel();
  print(await subscription.affectedRows);
  print(await subscription.schema);

  await conn.close();

  app.use(loggerMiddleware);

  // app.get('/', (req, res) => res.ok('testing'));

  // final conn = await Connection.open(Endpoint(
  //   host: 'localhost',
  //   database: 'postgres',
  //   username: 'user',
  //   password: 'pass',
  // ));
  app.get('/foo', (req, res) => res.ok("bar"));

  final guestRouter = Pharaoh.router;
  app.get('/user', (req, res) => res.ok("Hello World"));
  app.post('/post', (req, res) => res.json({"mee": "moo"}));
  app.put('/put', (req, res) => res.json({"pookey": "reyrey"}));

  app.group('/guest', guestRouter);

  app.get('/', ((req, res) => res.ok('testing')));
  app.get('/websocket', (req, res) => res.ok('postgres'));

  await app.listen();
}
