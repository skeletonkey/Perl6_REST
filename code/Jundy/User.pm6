use v6;

use JSON::Fast;

use Jundy::DB;
use Erik;
my $erik = Erik.new;

class Jundy::User is Jundy::DB {
    has $.id;
    has $.uuid;
    has $.username;
    has $.name;
    has $.email;
    has $.password;
    has $.created;
    has $.active;

    method save {
        if self.uuid {
            my $sth = self.dbh.prepare(q+update user set username = ?, name = ? , email = ?, password = ? where uuid = ?+);
            $sth.execute(self.username, self.name, self.email, self.password, self.uuid);

            return self.load;
        }
        else {
            my $sth = self.dbh.prepare(q:to/STATEMENT/);
                INSERT INTO user
                (uuid,   username, name, email, password, created)
                VALUES
                (uuid(), ?,        ?,    ?,     ?,        now())
            STATEMENT
            $sth.execute(self.username, self.name, self.email, self.password);
        }
    }

    method load {

    }
}