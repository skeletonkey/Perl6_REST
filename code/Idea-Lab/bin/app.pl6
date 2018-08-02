use lib '/code';

use v6;

use Bailador;
use DBIish;
use JSON::Fast;

use Erik;
use Jundy::DB;
use Jundy::Model::User;
use Jundy::View::User;

my $version = '0.0.1';
my $erik = Erik.new;

get '/' => sub {
    content_type('text/html');
    my $temp = 1000.rand;

    $erik.log("Hello World via log method: " ~ $temp);

    template 'index.html', { version => $version ~ $temp };
}

get '/users' => sub () {
    $erik.log("Get all users");

    status 200;

    my @users = Jundy::Model::User.new.get;

    status 404 unless @users.elems;

    return Jundy::View::User.new.render(@users);
}

get '/users/raw' => sub () {
    $erik.log("Get all users [RAW]");
    my $db = Jundy::DB.new;
    my $test = $db.dbh;
    my $sth = $test.prepare('SELECT * FROM user');
    $sth.execute();
    my @rows = $sth.allrows(:array-of-hash);

    return to-json @rows;
}

get '/users/:uuid' => sub ($uuid) {
    $erik.log("Looking up User ID: " ~ $uuid);

    status 200;

    my @users = Jundy::Model::User.new.get($uuid);

    status 404 unless @users.elems;

    return Jundy::View::User.new.render(@users);
}

post '/users' => sub {
    $erik.log("POST /users");
    $erik.log("body: " ~ request.body);

    my $session = session;

    if $session<uuid>:exists {
        my $data = Jundy::View::User.new.parse(request.body);

        $erik.log("User created by " ~ $session<uuid>);
        $erik.log("data - name:" ~ $data<username> ~ "|full_name:" ~ $data<name> ~ "|password:" ~ $data<password>);

        my $uuid = Jundy::Model::User.new.create($data);
        if $uuid {
            header('location', '/users/' ~ $uuid);
            status 201;
        }
        else {
            status 400;
        }
    }
    else {
        status 401;
        $erik.log("User not logged in!")
    }


    return '';
}

get '/healthcheck' => sub {
    my %status = (
        overallStatus => "OK",
        results       => [],
    );


    # mysql
    my $dbh = Jundy::DB.new.dbh;
    my $sth = $dbh.prepare('SELECT 1');
    $sth.execute;
    my @data = $sth.row();

    my %mysql_status = (
        dependency => {
            name        => 'Mysql - sharing_is_caring',
            isCritical  => 1,
            methodology => 'See if able to execute query',
            uri         => ''
        },
        statusResponse => {
            statusDescription => 'Unable to connect',
            status => 'Failure',
        },
    );
    if (@data[0] == 1) {
        %mysql_status<statusResponse>{'statusDescription'} = 'OK';
        %mysql_status<statusResponse><status> = 'Success';
    }
    %status<results>.push(%mysql_status);


    for %status<results> -> $ind_status {
        if $ind_status[0]<statusResponse><status> eq 'Failure' {
            %status<overallStatus> = 'Failure';
            last;
        }
    }

    return to-json %status;
}

get post '/logout' => sub {
    my $session = session;
    if $session<uuid>:exists {
        $session<uuid>:delete;
    }

    status 200;
    return '';
}

post '/login' => sub {
    my $params = from-json(request.body);

    my $status_code = 200;
    my $return_data = '';
    if $params<username>:exists and $params<password>:exists {
        $erik.log("Log in attempt for " ~ $params<username>);
        my $sth = Jundy::DB.new.dbh.prepare('SELECT uuid FROM user WHERE username = ? and password = ?');
        $sth.execute($params<username>, $params<password>);
        my %user_data = $sth.row(:hash);

        if %user_data<uuid> {
            $erik.log("User logged in: " ~ %user_data<uuid>);
            my $session = session;
            $session<uuid> = %user_data<uuid>;
        }
        else {
            $status_code = 401;
            $return_data = '{"error":"Unable to validate login information"}';
        }
    }
    else {
        $status_code = 401;
        $return_data = '{"error":"User name or Password not provided"}';
    }

    status $status_code;
    return $return_data;
}

## boards
#post '/boards' => sub {
#    my $session = session;

#    my $status_code = 401;
#    my $return_data = '{"error":"You are not logged in"}';

#    if $session<uuid>:exists {
#        $status_code = 200;
#        $return_data = '{"data": "You are logged in - too bad there is no logic"}';
#    }

#    status $status_code;
#    return $return_data;
#}

baile();
