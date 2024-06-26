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
      settings: ConnectionSettings(sslMode: SslMode.disable));

  print(conn.execute("SELECT 1"));

  final result = await conn.execute("SELECT 'foo'");
  print(result[0][0]); // first row and first field

  // final loggerMiddleware = (Request req, Response res, NextFunction next) {
  //   print(req.headers);

  //   next();
  // }

  app.use(loggerMiddleware);

  // app.get('/', (req, res) => res.ok('testing'));

  // final conn = await Connection.open(Endpoint(
  //   host: 'localhost',
  //   database: 'postgres',
  //   username: 'user',
  //   password: 'pass',
  // ));

  app.get('/', ((req, res) => res.ok('testing')));
  app.get('/websocket', (req, res) => res.ok('testing'));

  await app.listen();
}
