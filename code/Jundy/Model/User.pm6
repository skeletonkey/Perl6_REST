use v6;

use JSON::Fast;

use Jundy::DB;
use Jundy::User;
use Erik;
my $erik = Erik.new;

class Jundy::Model::User is Jundy::DB {
    multi submethod get {
        Erik.log("get_all");
        my $sth = self.dbh.prepare('SELECT * FROM user');
        $sth.execute();

        return self!get_user_data($sth);
    }

    multi submethod get($uuid) {
        Erik.log("get data for " ~ $uuid);
        my $sth = self.dbh.prepare('SELECT * FROM user where uuid = ?');
        $sth.execute($uuid);

        return self!get_user_data($sth);
    }

    method !get_user_data($sth) {
        my @users;
        for $sth.allrows(:array-of-hash) -> %href {
            my $user = Jundy::User.new(
                active   => %href<active>,
                created  => %href<created>,
                email    => %href<email>,
                id       => %href<id>,
                name     => %href<name>.map({ .chr }).join(''),
                password => %href<password>.map({ .chr }).join(''),
                username => %href<username>,
                uuid     => %href<uuid>,
            );
            @users.push($user);
        }

        return @users;
    }

    submethod create($user_data) {
        my $uuid = 0;

        my $sth = self.dbh.prepare(q:to/STATEMENT/);
            INSERT INTO user
            (uuid,   username, name, email, password, created)
            VALUES
            (uuid(), ?,        ?,    ?,     ?,        now())
        STATEMENT
        $erik.log("executing");
        try $sth.execute($user_data<username>, $user_data<name>, $user_data<email>, $user_data<password>);
        if ($!) {
            $erik.log("error found: " ~ $!);
            $erik.log("DB error code: " ~ $sth.err);
            $erik.log("DB error: " ~ $sth.errstr);
        }
        else {
            $sth = self.dbh.prepare('SELECT uuid FROM user WHERE username = ?');
            $erik.log("Username: " ~ $user_data<username>);
            $sth.execute($user_data<username>);
            my %user_data = $sth.row(:hash);

            $erik.log("New user ID: " ~ %user_data<uuid>);

            $uuid = %user_data<uuid>;
        }

        return $uuid;
    }
}
