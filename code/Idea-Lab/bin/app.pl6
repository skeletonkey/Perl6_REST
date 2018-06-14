use lib '/code';

use v6;

use Bailador;
use DBIish;
use JSON::Fast;

my $version = '0.0.1';
my $tmp_file = '/tmp/erik.out';

my $dbh = DBIish.connect("mysql", :user<lab_worker>, :password<worker123!>, :database<idea_lab>);

app.config.default-content-type = 'application/json';

get '/' => sub {
    content_type('text/html');
    my $temp = 1000.rand;

    log("Hello World via log method: " ~ $temp);

    template 'index.html', { version => $version ~ $temp };
}

get '/users' => sub () {
    log("Get all users");
    my $sth = $dbh.prepare('SELECT * FROM user');
    $sth.execute();
    my @rows = $sth.allrows(:array-of-hash);

    return to-json @rows;
}

post '/users' => sub {
    my $params = from-json(request.body);

    log("POST /users name:" ~ $params<name> ~ "|full_name:" ~ $params<full_name> ~ "|password:" ~ $params<password>);
    if $params<username>:exists and $params<name>:exists and $params<email>:exists and $params<password>:exists {
        my $sth = $dbh.prepare(q:to/STATEMENT/);
            INSERT INTO user
            (uuid,   username, name, email, password, created)
            VALUES
            (uuid(), ?,        ?,    ?,     ?,        now())
        STATEMENT
        $sth.execute($params<username>, $params<name>, $params<email>, $params<password>);

        $sth = $dbh.prepare('SELECT id FROM user WHERE username = ?');
        $sth.execute($params<username>);
        my %user_data = $sth.row(:hash);

        header('location', '/users/' ~ %user_data<uuid>);
        log("Successfully Created");
        status 201;
    }
    else {
        log("Error");
        status 400;
    }

    return '';
}

get '/users/:uuid' => sub ($uuid) {
    log("Looking up User ID: " ~ $uuid);
    my $sth = $dbh.prepare(q:to/STATEMENT/);
        SELECT * FROM user WHERE uuid = ?
        STATEMENT
    $sth.execute($uuid);
    if $sth.rows == 1 {
        my %data = $sth.row(:hash);
        return to-json %data;
    }
    else {
        status 404;
        return '';
    }
}

sub log ($msg) {
    my $fh = $tmp_file.IO.open: :a;
    $fh.say($msg);
    $fh.close;
}

get '/healthcheck' => sub {
    content_type('application/json');

    my %status = (
        overallStatus => "OK",
        results       => [],
    );


    # mysql
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

baile();
