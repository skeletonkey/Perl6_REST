use v6;

use Jundy::View;

class Jundy::View::User is Jundy::View {
    submethod render(@users) {
        my @display;
        for @users -> $user {
            my %temp =
                uuid => $user.uuid,
                name => $user.name,
                email => $user.email,
                username => $user.username,
            ;
            @display.push(%temp);
        }

        return self.encode(@display);
    }

    submethod parse($content) {
        return self.decode($content);
    }
}
