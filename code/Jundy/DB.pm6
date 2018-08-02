use v6;

use DBIish;

class Jundy::DB {
    has $.dbh = DBIish.connect("mysql", :user<lab_worker>, :password<worker123!>, :database<idea_lab>);
}
